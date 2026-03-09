#include <Core/DeduplicateInsert.h>

#include <Core/Settings.h>
#include <Common/Logger.h>
#include <Common/logger_useful.h>
#include <Common/Exception.h>
#include <Interpreters/Context.h>

namespace DB
{

namespace ErrorCodes
{
    extern const int DEDUPLICATION_IS_NOT_POSSIBLE;
}

namespace Setting
{
    extern const SettingsBool async_insert;
    extern const SettingsBool async_insert_deduplicate;
    extern const SettingsBool insert_deduplicate;
    extern const SettingsDeduplicateInsertMode deduplicate_insert;
    extern const SettingsDeduplicateInsertSelectMode deduplicate_insert_select;
    extern const SettingsString insert_deduplication_token;
}

bool isDeduplicationEnabledForInsert(bool is_async_insert, const Settings & settings)
{
    switch (settings[Setting::deduplicate_insert].value)
    {
        case DeduplicateInsertMode::BACKWARD_COMPATIBLE_CHOICE:
            return is_async_insert ? settings[Setting::async_insert_deduplicate] : settings[Setting::insert_deduplicate];
        case DeduplicateInsertMode::ENABLE:
            return true;
        case DeduplicateInsertMode::DISABLE:
            return false;
    }
}

bool isDeduplicationEnabledForInsert(const Settings & settings)
{
    return isDeduplicationEnabledForInsert(settings[Setting::async_insert], settings);
}

bool isDeduplicationEnabledForInsertSelect(bool select_query_sorted, const Settings & settings, LoggerPtr logger)
{
    switch (settings[Setting::deduplicate_insert_select].value)
    {
        case DeduplicateInsertSelectMode::FORCE_ENABLE:
        {
            if (!select_query_sorted)
                throw Exception(ErrorCodes::DEDUPLICATION_IS_NOT_POSSIBLE,
                    "Deduplication for INSERT SELECT with non-stable SELECT is not possible"
                    " (the SELECT part can return different results on each execution)."
                    " You can disable it by setting `insert_deduplicate` or `async_insert_deduplicate` to 0."
                    " Or make SELECT query stable (for example, by adding ORDER BY all to the query).");

            return true;
        }
        case DeduplicateInsertSelectMode::DISABLE:
            return false;
        case DeduplicateInsertSelectMode::ENABLE_EVEN_FOR_BAD_QUERIES:
        {
            if (logger && !select_query_sorted && isDeduplicationEnabledForInsert(false, settings))
                LOG_INFO(logger, "INSERT SELECT deduplication is enabled in compatibility mode, but SELECT is not stable. "
                    "The deduplication may not work as expected because the SELECT part can return different results on each execution.");

            return isDeduplicationEnabledForInsert(false, settings);
        }
        case DeduplicateInsertSelectMode::ENABLE_WHEN_POSSIBLE:
        {
            /// If an explicit deduplication token is provided, enable deduplication regardless
            /// of SELECT stability. The user's token serves as the idempotency key, so they
            /// are explicitly opting into idempotent INSERT SELECT behavior (e.g., for safe retries).
            bool has_user_token = !settings[Setting::insert_deduplication_token].value.empty();
            if (has_user_token)
            {
                if (logger && !select_query_sorted && isDeduplicationEnabledForInsert(false, settings))
                    LOG_INFO(logger, "INSERT SELECT deduplication is enabled because insert_deduplication_token is explicitly set, "
                        "even though SELECT is not fully sorted (ORDER BY ALL). "
                        "Note: if the SELECT returns rows in different order between retries, "
                        "only blocks that hash to the same deduplication token will be deduplicated.");
                return isDeduplicationEnabledForInsert(false, settings);
            }

            if (logger && !select_query_sorted && isDeduplicationEnabledForInsert(false, settings))
                LOG_INFO(logger, "INSERT SELECT deduplication is disabled because SELECT is not stable");

            return select_query_sorted && isDeduplicationEnabledForInsert(false, settings);
        }
    }
}

void overrideDeduplicationSetting(bool is_on, ContextMutablePtr context)
{
    if (is_on)
        context->setSetting("deduplicate_insert", Field{"enable"});
    else
        context->setSetting("deduplicate_insert", Field{"disable"});
}

}
