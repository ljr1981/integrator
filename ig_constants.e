note
	description: "[
		Abstract notion of {IG_CONSTANTS}
		]"
	design: "[
		A collection of system-wide constants.
		]"

deferred class
	IG_CONSTANTS

feature {NONE} -- Implementation: Constants

	Github_path: PATH
			-- `Github_path' from system.
		once
			create Result.make_from_string (github_path_string)
		end

	Github_path_string: STRING
			-- `Github_path_string' from {EXECUTION_ENVIRONMENT}.
		local
			l_env: EXECUTION_ENVIRONMENT
		once
			create l_env
			check attached {STRING_32} l_env.starting_environment.item ("GITHUB") as al_path_string then
				Result := al_path_string
			end
		end

	dot_git_string: STRING = ".git"
	dot_gitignore_string: STRING = ".gitignore"
	git_config_string: STRING = "config"
	EIFGENs_string: STRING = "EIFGENs"
	ecf_extension_string: STRING = "ecf"

end
