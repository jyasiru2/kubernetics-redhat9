package main

# Do Not store secrets in ENV variables
secrets_env = [
    "passwd",
    "password",
    "pass",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

deny[msg] {
    input.Cmd == "env"
    val := input.Value
    contains(lower(val[_]), secrets_env[_])
    msg = sprintf("Potential secret in ENV key found: %s", [val])
}

# Only use trusted base images
deny[msg] {
    input.Cmd == "from"
    val := split(input.Value[0], "/")
    count(val) > 1
    msg = "Use a trusted base image"
}

# Do not use 'latest' tag for base images
deny[msg] {
    input.Cmd == "from"
    val := split(input.Value[0], ":")
    contains(lower(val[1]), "latest")
    msg = "Do not use 'latest' tag for base images"
}

# Avoid curl bashing
deny[msg] {
    input.Cmd == "run"
    val := concat(" ", input.Value)
    matches := regex.find_n("(curl|wget)[^|^>]*[|>]", lower(val), -1)
    count(matches) > 0
    msg = "Avoid curl bashing"
}

# Do not upgrade your system packages
warn[msg] {
    input.Cmd == "run"
    val := concat(" ", input.Value)
    matches := regex.match(".*?(apk|yum|dnf|apt|pip).+?(install|[dist-|check-|group]?up[grade|date]).*", lower(val))
    matches == true
    msg = sprintf("Do not upgrade your system packages: %s", [val])
}

# Do not use ADD if possible
deny[msg] {
    input.Cmd == "add"
    msg = "Use COPY instead of ADD"
}

# Any user...
any_user {
    input.Cmd == "user"
}

# ... but do not root
forbidden_users = [
    "root",
    "toor",
    "0"
]

deny[msg] {
    command := "user"
    users := [name | input.Cmd == "user"; name := input.Value]
    lastuser := users[count(users)-1]
    contains(lower(lastuser[_]), forbidden_users[_])
    msg = sprintf("Last USER directive (USER %s) is forbidden", [lastuser])
}

# Do not sudo
deny[msg] {
    input.Cmd == "run"
    val := concat(" ", input.Value)
    contains(lower(val), "sudo")
    msg = "Do not use 'sudo' command"
}

# Use multi-stage builds
default multi_stage = false
multi_stage = true {
    input.Cmd == "copy"
    val := concat(" ", input.Flags)
    contains(lower(val), "--from=")
}
deny[msg] {
    multi_stage == false
    msg = "You COPY, but do not appear to use multi-stage builds..."
}
