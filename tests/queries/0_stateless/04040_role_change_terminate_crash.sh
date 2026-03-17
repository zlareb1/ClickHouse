#!/usr/bin/env bash
# Tags: no-fasttest
# Regression test for std::terminate crash via role-change notification path
# when disallow_config_defined_profiles_for_sql_defined_users is enabled.
#
# When a SQL user has a role that includes a config-defined profile and
# disallow_config_defined_profiles_for_sql_defined_users is enabled:
#   - New connections correctly get ACCESS_DENIED (tested in 04010)
#   - But if a role is modified while an existing session is active,
#     the change notification fires ContextAccess::setRolesInfo from the
#     noexcept destructor of scope_guard in RoleCache::roleChanged.
#     mergeSettingsAndConstraintsFor throws ACCESS_DENIED inside that
#     noexcept destructor, which calls std::terminate and crashes the server.
#
# After the fix: the exception is caught and logged; server stays alive.
# Before the fix: std::terminate is called; server crashes.

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../shell_config.sh
. "$CURDIR"/../shell_config.sh

P="${CLICKHOUSE_TEST_UNIQUE_NAME}"

cleanup()
{
    ${CLICKHOUSE_CLIENT} -q "DROP USER IF EXISTS ${P}_u"    2>/dev/null || true
    ${CLICKHOUSE_CLIENT} -q "DROP ROLE IF EXISTS ${P}_role" 2>/dev/null || true
}
trap cleanup EXIT

# 'readonly' is a config-defined profile (programs/server/users.xml).
${CLICKHOUSE_CLIENT} -q "DROP ROLE IF EXISTS ${P}_role"
${CLICKHOUSE_CLIENT} -q "DROP USER IF EXISTS ${P}_u"
${CLICKHOUSE_CLIENT} -q "CREATE ROLE ${P}_role SETTINGS PROFILE 'readonly'"
${CLICKHOUSE_CLIENT} -q "CREATE USER ${P}_u IDENTIFIED WITH no_password"
${CLICKHOUSE_CLIENT} -q "GRANT ${P}_role TO ${P}_u"
${CLICKHOUSE_CLIENT} -q "ALTER USER ${P}_u DEFAULT ROLE ${P}_role"

# Open a persistent session as the affected user.
# This keeps a ContextAccess alive with subscription_for_roles_changes registered
# inside EnabledRoles. The subscription callback is queued into the scope_guard
# `notifications` in RoleCache::roleChanged, which has an implicitly noexcept
# destructor (BasicScopeGuard::~BasicScopeGuard, scope_guard.h:50).
${CLICKHOUSE_CLIENT} --user "${P}_u" -q "SELECT sleep(5)" &
BG_PID=$!
sleep 0.5   # allow connection to establish and role-cache subscription to register

# ALTER ROLE fires access_control.subscribeForChanges -> RoleCache::roleChanged
# -> collectEnabledRoles -> EnabledRoles::setRolesInfo joins ContextAccess callback
# into notifications -> ~scope_guard fires callback (noexcept context!)
# -> ContextAccess::setRolesInfo -> getEnabledSettings -> mergeSettingsAndConstraintsFor
# -> throws ACCESS_DENIED inside noexcept destructor -> std::terminate (before fix).
${CLICKHOUSE_CLIENT} -q "ALTER ROLE ${P}_role SETTINGS max_threads = 2"

wait "${BG_PID}" || true
sleep 0.3   # give the server a moment if it is going to crash

# If the server crashed the query below will fail (connection refused / EOF),
# producing no stdout — the reference mismatch will fail the test.
${CLICKHOUSE_CLIENT} --connect_timeout 3 -q "SELECT 'server_alive'"
