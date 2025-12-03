Using queries from '/home/ubuntu/ClickHouse/tests/queries' directory
Connecting to ClickHouse server... OK
Connected to server 25.11.1.1 @ 64700d51742a69e4e4e1aa9e6202906191ef721f test/statistics_cache
Found 1 parallel tests and 0 sequential tests
Running about 1 stateless tests (Process-3).
03212_variant_dynamic_cast_or_default:                                  [ FAIL ] 2.94 sec.
Reason: return code:  115
[ip-10-2-3-62] 2025.11.06 09:53:59.267547 [ 81421 ] {aef40b88-d7de-424d-94fb-a8fcf1669e18} <Error> executeQuery: Code: 115. DB::Exception: Unknown setting 'dynamic_serialization_version': In scope SELECT 'ch_dbg_env' AS tag, version() AS ver, getSetting('session_timezone') AS tz, getSetting('dynamic_serialization_version') AS dyn_ser, getSetting('object_serialization_version') AS obj_ser, getSetting('object_shared_data_serialization_version') AS obj_shared_ser FROM system.one WHERE ((SELECT count() FROM t WHERE toIPv4OrDefault(d) NOT IN (toIPv4('0.0.0.0'), toIPv4('192.168.0.1'))) + (SELECT count() FROM t WHERE toIPv6OrDefault(d) NOT IN (toIPv6('::'), toIPv6('::1'), toIPv6('::ffff:192.168.0.1')))) > 0. (UNKNOWN_SETTING) (version 25.11.1.1) (from [::ffff:127.0.0.1]:47370) (comment: 03212_variant_dynamic_cast_or_default.sql-test_o8vqbqo8) (query 78, line 146) (in query: SELECT 'ch_dbg_env' AS tag, version() AS ver, getSetting('session_timezone') AS tz, getSetting('dynamic_serialization_version') AS dyn_ser, getSetting('object_serialization_version') AS obj_ser, getSetting('object_shared_data_serialization_version') AS obj_shared_ser FROM system.one WHERE (SELECT count() FROM t WHERE toIPv4OrDefault(d) NOT IN (toIPv4('0.0.0.0'), toIPv4('192.168.0.1'))) + (SELECT count() FROM t WHERE toIPv6OrDefault(d) NOT IN (toIPv6('::'), toIPv6('::1'), toIPv6('::ffff:192.168.0.1'))) > 0;), Stack trace (when copying this message, always include the lines below):

0. /home/ubuntu/ClickHouse/contrib/llvm-project/libcxx/include/__exception/exception.h:113: std::exception::capture() @ 0x00000000106269e4
1. /home/ubuntu/ClickHouse/contrib/llvm-project/libcxx/include/__exception/exception.h:85: std::exception::exception[abi:se190107]() @ 0x00000000106269ac
2. /home/ubuntu/ClickHouse/base/poco/Foundation/src/Exception.cpp:27: Poco::Exception::Exception(String const&, int) @ 0x0000000034e13de4
3. /home/ubuntu/ClickHouse/src/Common/Exception.cpp:129: DB::Exception::Exception(DB::Exception::MessageMasked&&, int, bool) @ 0x000000001a659db0
4. /home/ubuntu/ClickHouse/src/Common/Exception.h:123: DB::Exception::Exception(String&&, int, String, bool) @ 0x0000000010620ab4
5. /home/ubuntu/ClickHouse/src/Common/Exception.h:58: DB::Exception::Exception(PreformattedMessage&&, int) @ 0x000000001061f8e0
6. /home/ubuntu/ClickHouse/src/Common/Exception.h:141: DB::Exception::Exception<String>(int, FormatStringHelperImpl<std::type_identity<String>::type>, String&&) @ 0x000000001061f710
7. /home/ubuntu/ClickHouse/src/Core/BaseSettings.cpp:55: DB::BaseSettingsHelpers::throwSettingNotFound(std::basic_string_view<char, std::char_traits<char>>) @ 0x0000000021ca518c
8. /home/ubuntu/ClickHouse/src/Core/BaseSettings.h:649: ? @ 0x00000000221b391c
9. /home/ubuntu/ClickHouse/src/Core/BaseSettings.h:280: DB::BaseSettings<DB::SettingsTraits>::get(std::basic_string_view<char, std::char_traits<char>>) const @ 0x00000000221b37b4
10. /home/ubuntu/ClickHouse/src/Core/Settings.cpp:7601: DB::Settings::get(std::basic_string_view<char, std::char_traits<char>>) const @ 0x0000000021e444c0
11. /home/ubuntu/ClickHouse/src/Functions/getSetting.cpp:73: DB::(anonymous namespace)::FunctionGetSetting<(DB::(anonymous namespace)::ErrorHandlingMode)0>::getValue(std::vector<DB::ColumnWithTypeAndName, std::allocator<DB::ColumnWithTypeAndName>> const&) const @ 0x0000000013c34128
12. /home/ubuntu/ClickHouse/src/Functions/getSetting.cpp:47: DB::(anonymous namespace)::FunctionGetSetting<(DB::(anonymous namespace)::ErrorHandlingMode)0>::getReturnTypeImpl(std::vector<DB::ColumnWithTypeAndName, std::allocator<DB::ColumnWithTypeAndName>> const&) const @ 0x0000000013c33da8
13. /home/ubuntu/ClickHouse/src/Functions/IFunctionAdaptors.h:132: DB::FunctionToOverloadResolverAdaptor::getReturnTypeImpl(std::vector<DB::ColumnWithTypeAndName, std::allocator<DB::ColumnWithTypeAndName>> const&) const @ 0x00000000134e07b0
14. /home/ubuntu/ClickHouse/src/Functions/IFunction.cpp:712: DB::IFunctionOverloadResolver::getReturnTypeWithoutLowCardinality(std::vector<DB::ColumnWithTypeAndName, std::allocator<DB::ColumnWithTypeAndName>> const&) const @ 0x000000002060ef98
15. /home/ubuntu/ClickHouse/src/Functions/IFunction.cpp:644: DB::IFunctionOverloadResolver::getReturnType(std::vector<DB::ColumnWithTypeAndName, std::allocator<DB::ColumnWithTypeAndName>> const&) const @ 0x000000002060eafc
16. /home/ubuntu/ClickHouse/src/Functions/IFunction.cpp:673: DB::IFunctionOverloadResolver::build(std::vector<DB::ColumnWithTypeAndName, std::allocator<DB::ColumnWithTypeAndName>> const&) const @ 0x000000002060f1e4
17. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/resolveFunction.cpp:1164: DB::QueryAnalyzer::resolveFunction(std::shared_ptr<DB::IQueryTreeNode>&, DB::IdentifierResolveScope&) @ 0x000000002323e0c0
18. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/QueryAnalyzer.cpp:2873: DB::QueryAnalyzer::resolveExpressionNode(std::shared_ptr<DB::IQueryTreeNode>&, DB::IdentifierResolveScope&, bool, bool, bool) @ 0x0000000022ec665c
19. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/QueryAnalyzer.cpp:3024: DB::QueryAnalyzer::resolveExpressionNodeList(std::shared_ptr<DB::IQueryTreeNode>&, DB::IdentifierResolveScope&, bool, bool) @ 0x0000000022ec5298
20. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/QueryAnalyzer.cpp:3348: DB::QueryAnalyzer::resolveProjectionExpressionNodeList(std::shared_ptr<DB::IQueryTreeNode>&, DB::IdentifierResolveScope&) @ 0x0000000022edabc0
21. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/QueryAnalyzer.cpp:4782: DB::QueryAnalyzer::resolveQuery(std::shared_ptr<DB::IQueryTreeNode> const&, DB::IdentifierResolveScope&) @ 0x0000000022ec1b50
22. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/QueryAnalyzer.cpp:136: DB::QueryAnalyzer::resolve(std::shared_ptr<DB::IQueryTreeNode>&, std::shared_ptr<DB::IQueryTreeNode> const&, std::shared_ptr<DB::Context const>) @ 0x0000000022ec05e8
23. /home/ubuntu/ClickHouse/src/Analyzer/Resolve/QueryAnalysisPass.cpp:18: DB::QueryAnalysisPass::run(std::shared_ptr<DB::IQueryTreeNode>&, std::shared_ptr<DB::Context const>) @ 0x0000000022ec0034
24. /home/ubuntu/ClickHouse/src/Analyzer/QueryTreePassManager.cpp:192: DB::QueryTreePassManager::run(std::shared_ptr<DB::IQueryTreeNode>) @ 0x0000000022f6086c
25. /home/ubuntu/ClickHouse/src/Interpreters/InterpreterSelectQueryAnalyzer.cpp:165: DB::buildQueryTreeAndRunPasses(std::shared_ptr<DB::IAST> const&, DB::SelectQueryOptions const&, std::shared_ptr<DB::Context const> const&, std::shared_ptr<DB::IStorage> const&) @ 0x0000000024122bc8
26. /home/ubuntu/ClickHouse/src/Interpreters/InterpreterSelectQueryAnalyzer.cpp:182: DB::InterpreterSelectQueryAnalyzer::InterpreterSelectQueryAnalyzer(std::shared_ptr<DB::IAST> const&, std::shared_ptr<DB::Context const> const&, DB::SelectQueryOptions const&, std::vector<String, std::allocator<String>> const&) @ 0x0000000024121b80
27. /home/ubuntu/ClickHouse/contrib/llvm-project/libcxx/include/__memory/unique_ptr.h:634: std::__unique_if<DB::InterpreterSelectQueryAnalyzer>::__unique_single std::make_unique[abi:se190107]<DB::InterpreterSelectQueryAnalyzer, std::shared_ptr<DB::IAST>&, std::shared_ptr<DB::Context> const&, DB::SelectQueryOptions const&>(std::shared_ptr<DB::IAST>&, std::shared_ptr<DB::Context> const&, DB::SelectQueryOptions const&) @ 0x0000000024124838
28. /home/ubuntu/ClickHouse/src/Interpreters/InterpreterSelectQueryAnalyzer.cpp:307: DB::registerInterpreterSelectQueryAnalyzer(DB::InterpreterFactory&)::$_0::operator()(DB::InterpreterFactory::Arguments const&) const @ 0x0000000024123f70
29. /home/ubuntu/ClickHouse/contrib/llvm-project/libcxx/include/__type_traits/invoke.h:149: decltype(std::declval<DB::registerInterpreterSelectQueryAnalyzer(DB::InterpreterFactory&)::$_0&>()(std::declval<DB::InterpreterFactory::Arguments const&>())) std::__invoke[abi:se190107]<DB::registerInterpreterSelectQueryAnalyzer(DB::InterpreterFactory&)::$_0&, DB::InterpreterFactory::Arguments const&>(DB::registerInterpreterSelectQueryAnalyzer(DB::InterpreterFactory&)::$_0&, DB::InterpreterFactory::Arguments const&) @ 0x0000000024123f20
30. /home/ubuntu/ClickHouse/contrib/llvm-project/libcxx/include/__type_traits/invoke.h:216: std::unique_ptr<DB::IInterpreter, std::default_delete<DB::IInterpreter>> std::__invoke_void_return_wrapper<std::unique_ptr<DB::IInterpreter, std::default_delete<DB::IInterpreter>>, false>::__call[abi:se190107]<DB::registerInterpreterSelectQueryAnalyzer(DB::InterpreterFactory&)::$_0&, DB::InterpreterFactory::Arguments const&>(DB::registerInterpreterSelectQueryAnalyzer(DB::InterpreterFactory&)::$_0&, DB::InterpreterFactory::Arguments const&) @ 0x0000000024123ea0
31. /home/ubuntu/ClickHouse/contrib/llvm-project/libcxx/include/__functional/function.h:210: ? @ 0x0000000024123e60

Received exception from server (version 25.11.1):
Code: 115. DB::Exception: Received from localhost:9000. DB::Exception: Unknown setting 'dynamic_serialization_version': In scope SELECT 'ch_dbg_env' AS tag, version() AS ver, getSetting('session_timezone') AS tz, getSetting('dynamic_serialization_version') AS dyn_ser, getSetting('object_serialization_version') AS obj_ser, getSetting('object_shared_data_serialization_version') AS obj_shared_ser FROM system.one WHERE ((SELECT count() FROM t WHERE toIPv4OrDefault(d) NOT IN (toIPv4('0.0.0.0'), toIPv4('192.168.0.1'))) + (SELECT count() FROM t WHERE toIPv6OrDefault(d) NOT IN (toIPv6('::'), toIPv6('::1'), toIPv6('::ffff:192.168.0.1')))) > 0. (UNKNOWN_SETTING)
(query: SELECT 'ch_dbg_env' AS tag,
       version() AS ver,
       getSetting('session_timezone') AS tz,
       getSetting('dynamic_serialization_version') AS dyn_ser,
       getSetting('object_serialization_version') AS obj_ser,
       getSetting('object_shared_data_serialization_version') AS obj_shared_ser
FROM system.one
WHERE
  (SELECT count() FROM t WHERE toIPv4OrDefault(d) NOT IN (toIPv4('0.0.0.0'), toIPv4('192.168.0.1')))
+ (SELECT count() FROM t WHERE toIPv6OrDefault(d) NOT IN (toIPv6('::'), toIPv6('::1'), toIPv6('::ffff:192.168.0.1')))
  > 0;)
, result:

0	\N
1	1
0	str_2
0	[0,1,2]
0	\N
5	5
0	str_6
0	[0,1,2,3,4,5,6]
\N	\N
1	1
\N	str_2
\N	[0,1,2]
\N	\N
5	5
\N	str_6
\N	[0,1,2,3,4,5,6]
0	\N
1	1
0	str_2
0	[0,1,2]
0	\N
5	5
0	str_6
0	[0,1,2,3,4,5,6]
\N	\N
1	1
\N	str_2
\N	[0,1,2]
\N	\N
5	5
\N	str_6
\N	[0,1,2,3,4,5,6]
-128
-127
-1
0
1
2
3
126
127
0
1
2
3
126
127
254
255
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
0
1
2
3
126
127
254
255
32766
32767
65534
65535
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
-9223372036854775808
-9223372036854775807
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
-170141183460469231731687303715884105728
-170141183460469231731687303715884105727
-9223372036854775808
-9223372036854775807
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
296245801836096677496328508227807879401
340282366920938463463374607431768211454
340282366920938463463374607431768211455
-57896044618658097711785492504343953926634992332820282019728792003956564819968
-57896044618658097711785492504343953926634992332820282019728792003956564819967
-170141183460469231731687303715884105728
-170141183460469231731687303715884105727
-9223372036854775808
-9223372036854775807
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
340282366920938463463374607431768211454
340282366920938463463374607431768211455
57896044618658097711785492504343953926634992332820282019728792003956564819966
57896044618658097711785492504343953926634992332820282019728792003956564819967
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
340282366920938463463374607431768211454
340282366920938463463374607431768211455
57896044618658097711785492504343953926634992332820282019728792003956564819966
57896044618658097711785492504343953926634992332820282019728792003956564819967
115792089237316195423570985008687907853269984665640564039457584007913129639934
115792089237316195423570985008687907853269984665640564039457584007913129639935
-inf
-3.4028233e38
-1.7014118e38
-9223372000000000000
-2147483600
-32768
-32767
-128
-127
-1
-1.1754942e-38
-1e-45
0
1e-45
1.1754942e-38
1
2
3
126
127
254
255
32766
32767
65534
65535
3.4028233e38
inf
nan
-inf
-1.7976931348623157e308
-5.78960446186581e76
-3.40282347e38
-3.4028232635611926e38
-1.7014118346046923e38
-9223372036854776000
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
-1.1754943499999998e-38
-1.1754942106924411e-38
-1.401298464324817e-45
-1.3999999999999999e-45
-2.2250738585072014e-308
0
2.2250738585072014e-308
1.3999999999999999e-45
1.401298464324817e-45
1.1754942106924411e-38
1.1754943499999998e-38
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
3.4028232635611926e38
3.40282347e38
1.7976931348623157e308
inf
nan
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
-9223372036854775808
-9223372036854775807
-18446744073709551.616
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
-340282347000000000977176926486249829565.415
-9223372036854775808
-9223372036854775807
-18446744073709551.616
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
340282347000000000977176926486249829565.415
1970-01-01
1970-01-02
1970-01-03
1970-01-04
1970-05-07
1970-05-08
1970-09-12
1970-09-13
2038-01-19
2059-09-17
2059-09-18
2106-02-07
2149-06-05
2149-06-06
1900-01-01
1969-08-26
1969-08-27
1969-12-31
1970-01-01
1970-01-02
1970-01-03
1970-01-04
1970-05-07
1970-05-08
1970-09-12
1970-09-13
2038-01-19
2059-09-17
2059-09-18
2106-02-07
2149-06-05
2149-06-06
2299-12-31
1970-01-01 00:00:00
1970-01-01 00:00:01
1970-01-01 00:00:02
1970-01-01 00:00:03
1970-01-01 00:02:06
1970-01-01 00:02:07
1970-01-01 00:04:14
1970-01-01 00:04:15
1970-01-01 09:06:06
1970-01-01 09:06:07
1970-01-01 18:12:14
1970-01-01 18:12:15
2038-01-19 03:14:06
2038-01-19 03:14:07
2106-02-07 06:28:14
2106-02-07 06:28:15
0.0.0.0
192.168.0.1
::
::1
::ffff:192.168.0.1
00000000-0000-0000-0000-000000000000
dededdb6-7835-4ce4-8d11-b5de6f2820e9

stdout:
0	\N
1	1
0	str_2
0	[0,1,2]
0	\N
5	5
0	str_6
0	[0,1,2,3,4,5,6]
\N	\N
1	1
\N	str_2
\N	[0,1,2]
\N	\N
5	5
\N	str_6
\N	[0,1,2,3,4,5,6]
0	\N
1	1
0	str_2
0	[0,1,2]
0	\N
5	5
0	str_6
0	[0,1,2,3,4,5,6]
\N	\N
1	1
\N	str_2
\N	[0,1,2]
\N	\N
5	5
\N	str_6
\N	[0,1,2,3,4,5,6]
-128
-127
-1
0
1
2
3
126
127
0
1
2
3
126
127
254
255
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
0
1
2
3
126
127
254
255
32766
32767
65534
65535
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
-9223372036854775808
-9223372036854775807
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
-170141183460469231731687303715884105728
-170141183460469231731687303715884105727
-9223372036854775808
-9223372036854775807
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
296245801836096677496328508227807879401
340282366920938463463374607431768211454
340282366920938463463374607431768211455
-57896044618658097711785492504343953926634992332820282019728792003956564819968
-57896044618658097711785492504343953926634992332820282019728792003956564819967
-170141183460469231731687303715884105728
-170141183460469231731687303715884105727
-9223372036854775808
-9223372036854775807
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
340282366920938463463374607431768211454
340282366920938463463374607431768211455
57896044618658097711785492504343953926634992332820282019728792003956564819966
57896044618658097711785492504343953926634992332820282019728792003956564819967
0
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
3232235521
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
170141183460469231731687303715884105726
170141183460469231731687303715884105727
340282366920938463463374607431768211454
340282366920938463463374607431768211455
57896044618658097711785492504343953926634992332820282019728792003956564819966
57896044618658097711785492504343953926634992332820282019728792003956564819967
115792089237316195423570985008687907853269984665640564039457584007913129639934
115792089237316195423570985008687907853269984665640564039457584007913129639935
-inf
-3.4028233e38
-1.7014118e38
-9223372000000000000
-2147483600
-32768
-32767
-128
-127
-1
-1.1754942e-38
-1e-45
0
1e-45
1.1754942e-38
1
2
3
126
127
254
255
32766
32767
65534
65535
3.4028233e38
inf
nan
-inf
-1.7976931348623157e308
-5.78960446186581e76
-3.40282347e38
-3.4028232635611926e38
-1.7014118346046923e38
-9223372036854776000
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
-1.1754943499999998e-38
-1.1754942106924411e-38
-1.401298464324817e-45
-1.3999999999999999e-45
-2.2250738585072014e-308
0
2.2250738585072014e-308
1.3999999999999999e-45
1.401298464324817e-45
1.1754942106924411e-38
1.1754943499999998e-38
1
2
3
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
3.4028232635611926e38
3.40282347e38
1.7976931348623157e308
inf
nan
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
-9223372036854775808
-9223372036854775807
-18446744073709551.616
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
-340282347000000000977176926486249829565.415
-9223372036854775808
-9223372036854775807
-18446744073709551.616
-2147483648
-2147483647
-32768
-32767
-128
-127
-1
0
1
126
127
254
255
32766
32767
65534
65535
2147483646
2147483647
4294967294
4294967295
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
340282347000000000977176926486249829565.415
1970-01-01
1970-01-02
1970-01-03
1970-01-04
1970-05-07
1970-05-08
1970-09-12
1970-09-13
2038-01-19
2059-09-17
2059-09-18
2106-02-07
2149-06-05
2149-06-06
1900-01-01
1969-08-26
1969-08-27
1969-12-31
1970-01-01
1970-01-02
1970-01-03
1970-01-04
1970-05-07
1970-05-08
1970-09-12
1970-09-13
2038-01-19
2059-09-17
2059-09-18
2106-02-07
2149-06-05
2149-06-06
2299-12-31
1970-01-01 00:00:00
1970-01-01 00:00:01
1970-01-01 00:00:02
1970-01-01 00:00:03
1970-01-01 00:02:06
1970-01-01 00:02:07
1970-01-01 00:04:14
1970-01-01 00:04:15
1970-01-01 09:06:06
1970-01-01 09:06:07
1970-01-01 18:12:14
1970-01-01 18:12:15
2038-01-19 03:14:06
2038-01-19 03:14:07
2106-02-07 06:28:14
2106-02-07 06:28:15
0.0.0.0
192.168.0.1
::
::1
::ffff:192.168.0.1
00000000-0000-0000-0000-000000000000
dededdb6-7835-4ce4-8d11-b5de6f2820e9


Settings used in the test: --max_insert_threads 3 --group_by_two_level_threshold 1 --group_by_two_level_threshold_bytes 1 --distributed_aggregation_memory_efficient 1 --fsync_metadata 1 --output_format_parallel_formatting 0 --input_format_parallel_parsing 0 --min_chunk_bytes_for_parallel_parsing 14164681 --max_read_buffer_size 502610 --prefer_localhost_replica 0 --max_block_size 20789 --max_joined_block_size_rows 68874 --joined_block_split_single_row 0 --join_output_by_rowlist_perkey_rows_threshold 0 --max_threads 1 --optimize_append_index 0 --use_hedged_requests 1 --optimize_if_chain_to_multiif 1 --optimize_if_transform_strings_to_enum 1 --optimize_read_in_order 1 --optimize_or_like_chain 0 --optimize_substitute_columns 0 --enable_multiple_prewhere_read_steps 1 --read_in_order_two_level_merge_threshold 24 --optimize_aggregation_in_order 1 --aggregation_in_order_max_block_bytes 49577083 --use_uncompressed_cache 1 --min_bytes_to_use_direct_io 10737418240 --min_bytes_to_use_mmap_io 1 --local_filesystem_read_method read --remote_filesystem_read_method threadpool --local_filesystem_read_prefetch 0 --filesystem_cache_segments_batch_size 1 --read_from_filesystem_cache_if_exists_otherwise_bypass_cache 1 --throw_on_error_from_cache_on_write_operations 0 --remote_filesystem_read_prefetch 0 --allow_prefetched_read_pool_for_remote_filesystem 0 --filesystem_prefetch_max_memory_usage 32Mi --filesystem_prefetches_limit 10 --filesystem_prefetch_min_bytes_for_single_read_task 1Mi --filesystem_prefetch_step_marks 0 --filesystem_prefetch_step_bytes 100Mi --compile_expressions 0 --compile_aggregate_expressions 0 --compile_sort_description 0 --merge_tree_coarse_index_granularity 13 --optimize_distinct_in_order 0 --max_bytes_before_remerge_sort 1007660141 --min_compress_block_size 3007493 --max_compress_block_size 2593218 --merge_tree_compact_parts_min_granules_to_multibuffer_read 91 --optimize_sorting_by_input_stream_properties 1 --http_response_buffer_size 1691714 --http_wait_end_of_query True --enable_memory_bound_merging_of_aggregation_results 0 --min_count_to_compile_expression 0 --min_count_to_compile_aggregate_expression 0 --min_count_to_compile_sort_description 3 --session_timezone Etc/UTC --use_page_cache_for_disks_without_file_cache True --page_cache_inject_eviction True --merge_tree_read_split_ranges_into_intersecting_and_non_intersecting_injection_probability 0.77 --prefer_external_sort_block_bytes 100000000 --cross_join_min_rows_to_compress 1 --cross_join_min_bytes_to_compress 100000000 --min_external_table_block_size_bytes 0 --max_parsing_threads 1 --optimize_functions_to_subcolumns 0 --parallel_replicas_local_plan 1 --query_plan_join_swap_table false --enable_vertical_final 0 --optimize_extract_common_expressions 1 --use_async_executor_for_materialized_views 0 --use_query_condition_cache 0 --secondary_indices_enable_bulk_filtering 1 --use_skip_indexes_if_final 0 --use_skip_indexes_on_data_read 0 --optimize_rewrite_like_perfect_affix 1 --max_bytes_before_external_sort 0 --max_bytes_before_external_group_by 0 --max_bytes_ratio_before_external_sort 0.0 --max_bytes_ratio_before_external_group_by 0.2 --use_skip_indexes_if_final_exact_mode 0

MergeTree settings used in test: --ratio_of_defaults_for_sparse_serialization 0.6919553460112179 --prefer_fetch_merged_part_size_threshold 10737418240 --vertical_merge_algorithm_min_rows_to_activate 70959 --vertical_merge_algorithm_min_columns_to_activate 100 --allow_vertical_merges_from_compact_to_wide_parts 0 --min_merge_bytes_to_use_direct_io 3691240013 --index_granularity_bytes 12576106 --merge_max_block_size 10450 --index_granularity 13170 --min_bytes_for_wide_part 1073741824 --marks_compress_block_size 30781 --primary_key_compress_block_size 54447 --replace_long_file_name_to_hash 1 --max_file_name_length 128 --min_bytes_for_full_part_storage 536870912 --compact_parts_max_bytes_to_buffer 250842623 --compact_parts_max_granules_to_buffer 25 --compact_parts_merge_max_bytes_to_prefetch_part 23947737 --cache_populated_by_fetch 1 --concurrent_part_removal_threshold 42 --old_parts_lifetime 480 --prewarm_mark_cache 0 --use_const_adaptive_granularity 1 --enable_index_granularity_compression 1 --enable_block_number_column 1 --enable_block_offset_column 0 --use_primary_key_cache 0 --prewarm_primary_key_cache 0 --object_serialization_version v3 --object_shared_data_serialization_version advanced --object_shared_data_serialization_version_for_zero_level_parts map_with_buckets --object_shared_data_buckets_for_compact_part 16 --object_shared_data_buckets_for_wide_part 18 --dynamic_serialization_version v3 --auto_statistics_types uniq,countmin --serialization_info_version with_types --string_serialization_version with_size_stream --enable_shared_storage_snapshot_in_query 1

Database: test_o8vqbqo8

Having 1 errors! 0 tests passed. 0 tests skipped. 2.97 s elapsed (Process-3).
All tests have finished.
Too much memory has been allocated without checking for memory limits: 16.752238490618765 GiB
