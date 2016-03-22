note
	description: "Tests of {IG_ECF_SCANNER}."
	testing: "type/manual"

class
	IG_ECF_SCANNER_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as assert_old
		end

	EQA_COMMONLY_USED_ASSERTIONS
		undefine
			default_create
		end

	TEST_SET_BRIDGE
		undefine
			default_create
		end

	IG_ANY
		undefine
			default_create
		end

	IG_CONSTANTS
		undefine
			default_create
		end

feature -- Test routines

	integrator_basic_tests
			-- `integrator_basic_tests'
		local
			l_scanner: IG_ECF_SCANNER
		do
			create l_scanner
			l_scanner.scan_github
			assert_integers_equal ("has_120_you_may_have_more_or_less", 120, l_scanner.ecf_libraries.count)
			assert_integers_equal ("has_7_branches", 7, l_scanner.branch_count)
			assert_integers_equal ("has_14_leaves", 14, l_scanner.leaf_count)
			assert_integers_equal ("has_99_trunks", 99, l_scanner.trunk_count)
			assert_integers_equal ("branches_leaves_trunks_counts_are_ecf_libraries_count", l_scanner.ecf_libraries.count, l_scanner.trunk_count + l_scanner.branch_count + l_scanner.leaf_count)
			assert_integers_equal ("has_21_github_based_ecfs", 21, l_scanner.github_count)
			assert_integers_equal ("has_0_github_trunks", 0, l_scanner.github_trunk_count)
			assert_strings_equal ("the_ninety_nine", the_ninety_nine, the_ninety_nine_calculated (l_scanner.ecf_libraries))
			assert_strings_equal ("the_trunks", "", the_trunks (l_scanner.ecf_libraries))
			assert_strings_equal ("the_branches", "pub_sub,logging_extension,test_extension,randomizer,state_machine,test_set_helper,validation", the_branches (l_scanner.ecf_libraries))
			assert_strings_equal ("the_leaves", "abel_extension,accounting,ehrapp,ecfwingen,ecf_generator,ehtml,foxpro,framework,integrator,json_ext,test_set_bridge,permission,sav_training,tokenizer", the_leaves (l_scanner.ecf_libraries))
		end

	ise_eiffel_test
			-- `ise_eiffel_test'.
		note
			warning: "[
				This test will only pass on a Windows machine and using GPL of the same version.
				]"
		local
			l_env: EXECUTION_ENVIRONMENT
		do
			create l_env
			check attached l_env.starting_environment.item ("ISE_EIFFEL") as al_item then
				assert_strings_equal ("ise_eiffel_changed", Ise_eiffel_environment_variable, al_item.out)
			end
		end

	ise_library_test
			-- `ise_eiffel_test'.
		note
			warning: "[
				This test will only pass on a Windows machine and using GPL of the same version.
				]"
		local
			l_env: EXECUTION_ENVIRONMENT
		do
			create l_env
			check attached l_env.starting_environment.item ("ISE_LIBRARY") as al_item then
				assert_strings_equal ("ise_library_changed", Ise_library_environment_variable, al_item.out)
			end
		end

feature {NONE} -- Implementation: Constants

	the_trunks (a_ecf_libraries: HASH_TABLE [IG_ECF_CLIENT_SUPPLIER, STRING_8]): STRING
		do
			create Result.make_empty
			across
				a_ecf_libraries as ic_ecfs
			loop
				if ic_ecfs.item.is_trunk then
					Result.append_string (ic_ecfs.item.name + ",")
				end
			end
			if Result.count > 0 then
				Result.remove_tail (1)
			end
		end

	the_branches (a_ecf_libraries: HASH_TABLE [IG_ECF_CLIENT_SUPPLIER, STRING_8]): STRING
		do
			create Result.make_empty
			across
				a_ecf_libraries as ic_ecfs
			loop
				if ic_ecfs.item.is_branch then
					Result.append_string (ic_ecfs.item.name + ",")
				end
			end
			if Result.count > 0 then
				Result.remove_tail (1)
			end
		end

	the_leaves (a_ecf_libraries: HASH_TABLE [IG_ECF_CLIENT_SUPPLIER, STRING_8]): STRING
		do
			create Result.make_empty
			across
				a_ecf_libraries as ic_ecfs
			loop
				if ic_ecfs.item.is_leaf then
					Result.append_string (ic_ecfs.item.name + ",")
				end
			end
			if Result.count > 0 then
				Result.remove_tail (1)
			end
		end

	the_ninety_nine_calculated (a_ecf_libraries: HASH_TABLE [IG_ECF_CLIENT_SUPPLIER, STRING_8]): STRING
		do
			create Result.make_empty
			across
				a_ecf_libraries as ic_ecfs
			loop
				Result.append_string (ic_ecfs.item.name + "%N")
			end
		end

	the_ninety_nine: STRING = "[
abel_extension
accounting
pub_sub
ehrapp
ecfwingen
ecf_generator
ehtml
web_server
nino
service_file
atom
rss
oauth
wsf_js_widget
gewf
debug
desktop_app
filter
client
restbucks
hello_with_launcher
hello_with_execute
hello
hello
hello
upload_image
http_client
libcurl_http_client
http_client
test_http_client
conneg
test
http
tests
notification_email
demo
openid
tests
basic
http_authorization
testing
connector_cgi
connector_libfcgi
connector_nino
connector_cgi
httpd
connector_standalone
test_connector_standalone
ewsgi
ewsgi_spec
hello_world
libfcgi
eiffelweb
connector_libfcgi_v0
connector_nino_v0
ewsgi_v0
wsf_libfcgi_v0
wsf_nino_v0
default_libfcgi_v0
default_nino_v0
wsf_v0
wsf_extension_v0
wsf_policy_driven_v0
wsf_router_context_v0
wsf_html_v0
wsf_all
wsf_cgi
wsf_libfcgi
wsf_nino
wsf_openshift
wsf_standalone
default_cgi
default_libfcgi
default_nino
default_openshift
default_standalone
echo_server
wsf_tests
wsf
wsf_extension
wsf_policy_driven
wsf_router_context
wsf_session
wsf_html
encoder
encoder_tests
feed
tests
test_uri_template_draft_05
uri_template
error
error_tests
precomp_wsf-mt
precomp_wsf
precomp_wsf-scoop-safe
all
all
hello_dev
test
wizard
estudio_console_wizard
estudio_gui_wizard
wizard
foxpro
framework
integrator
json_ext
logging_extension
database_constraint
mask
test_extension
test_set_bridge
permission
randomizer
sav_training
state_machine
test_set_helper
tokenizer
validation
windows

]"

end
