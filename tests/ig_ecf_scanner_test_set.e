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
			l_projects: IG_ECF_SCANNER
			l_github_count,
			l_config_count: INTEGER
		do
			create l_projects
			l_projects.scan_github
			assert_integers_equal ("has_120_you_may_have_more_or_less", 120, l_projects.ecf_libraries.count)
			assert_integers_equal ("has_7_branches", 7, l_projects.branch_count)
			assert_integers_equal ("has_14_leaves", 14, l_projects.leaf_count)
			assert_integers_equal ("has_99_trunks", 99, l_projects.trunk_count)
			assert_integers_equal ("branches_leaves_trunks_counts_are_ecf_libraries_count", l_projects.ecf_libraries.count, l_projects.trunk_count + l_projects.branch_count + l_projects.leaf_count)
--			across
--				l_projects.ecf_libraries as ic_ecf
--			loop
--				if ic_ecf.item.github_path.name.has_substring (".\git") then
--					l_github_count := l_github_count + 1
--				end
--				if ic_ecf.item.github_config_path.name.has_substring (".\config") then
--					l_config_count := l_config_count + 1
--				end
--			end
--			assert_integers_equal ("gits_have_configs", l_github_count, l_config_count)
--			assert_integers_equal ("has_23_githubs_you_may_have_more_or_less", 23, l_github_count)
--			assert_integers_equal ("has_23_configs_you_may_have_more_or_less", 23, l_config_count)
				-- marking tests
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

end
