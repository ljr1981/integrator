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
			assert_integers_equal ("has_194_you_may_have_more_or_less", 194, l_scanner.ecf_libraries.count)
			assert_integers_equal ("has_9_branches", 9, l_scanner.branch_count)
			assert_integers_equal ("has_8_leaves", 8, l_scanner.leaf_count)
			assert_integers_equal ("has_96_trunks", 96, l_scanner.trunk_count)
			assert_integers_equal ("branches_leaves_trunks_counts_are_ecf_libraries_count", l_scanner.ecf_libraries.count, l_scanner.trunk_count + l_scanner.branch_count + l_scanner.leaf_count)
			assert_integers_equal ("has_17_github_based_ecfs", 17, l_scanner.github_count)
			assert_integers_equal ("has_0_github_trunks", 0, l_scanner.github_trunk_count)
			assert_strings_equal ("the_trunks", "", the_trunks (l_scanner.ecf_libraries))
			assert_strings_equal ("the_branches", "framework,github_helper,graphviz,logging_extension,pub_sub,randomizer,state_machine,test_extension,validation", the_branches (l_scanner.ecf_libraries))
			assert_strings_equal ("the_leaves", "ecfwingen,ecf_generator,ehrapp,ig_test_project,integrator,permission,reporting,sav_training", the_leaves (l_scanner.ecf_libraries))
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

	the_trunks (a_ecf_libraries: HASH_TABLE [IG_ECF, STRING_8]): STRING
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

	the_branches (a_ecf_libraries: HASH_TABLE [IG_ECF, STRING_8]): STRING
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

	the_leaves (a_ecf_libraries: HASH_TABLE [IG_ECF, STRING_8]): STRING
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

end
