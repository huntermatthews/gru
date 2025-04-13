## -*- mode: fish -*- ##

# from https://fishshell.com/docs/current/cmds/fish_git_prompt.html:
# "Boolean options (those which enable or disable something) understand “1”, “yes” or “true” to
# mean true and every other value to mean false." Should I add "True" to this list?
# Recall that for SHELL/fish programming, an 'if' test is reversed from normal boolean logic.
#      Think of it like this - did X fail? if X == 'did X fail?' -- which cause the true block to be '0'
#      Yes, shell programming is weird - its not my fault.
function is_true
    set truths true yes 1
    if contains $argv $truths
        return 0
    end
    return 1
end

function is_false
    set truths true yes 1
    if contains $argv $truths
        return 1
    end
    return 0
end

function is_false_or_empty
    # This is a bit of a hack - but it works.
    # We want to check for empty or false - so we check for empty first.
    # If its empty, we return success(0). If its not empty, we check for false.
    # If its false, we return success. If its not false, we return failure.
    if test -z $argv
        return 0
    end
    if is_false $argv
        return 0
    end
    return 1
end
