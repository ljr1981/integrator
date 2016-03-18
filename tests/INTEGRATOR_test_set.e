note
	description: "Tests of {INTEGRATOR}."
	testing: "type/manual"

class
	INTEGRATOR_TEST_SET

inherit
	EQA_TEST_SET
		rename
			assert as assert_old
		end

	EQA_COMMONLY_USED_ASSERTIONS
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
			assert_integers_equal ("has_130_you_may_have_more_or_less", 130, l_projects.ecf_libraries.count)
			across
				l_projects.ecf_libraries as ic_ecf
			loop
				if attached ic_ecf.item.github_path then
					l_github_count := l_github_count + 1
				end
				if attached ic_ecf.item.github_config_path then
					l_config_count := l_config_count + 1
				end
			end
			assert_integers_equal ("gits_have_configs", l_github_count, l_config_count)
			assert_integers_equal ("has_23_githubs_you_may_have_more_or_less", 23, l_github_count)
			assert_integers_equal ("has_23_configs_you_may_have_more_or_less", 23, l_config_count)
		end

end
