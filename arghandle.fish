# Compatible with fish 3.3.1 or higher

set --query arghandle_suppress_errors || set arghandle_suppress_errors

set --query arghandle_title_color || set arghandle_title_color green
set --query arghandle_option_color || set arghandle_option_color cyan
set --query arghandle_int_placeholder_color || set arghandle_int_placeholder_color red
set --query arghandle_float_placeholder_color || set arghandle_float_placeholder_color yellow
set --query arghandle_bool_placeholder_color || set arghandle_bool_placeholder_color green
set --query arghandle_str_placeholder_color || set arghandle_str_placeholder_color blue

set --query arghandle_option_mnemonic_color || set arghandle_option_mnemonic_color yellow
set --query arghandle_option_default_color || set arghandle_option_default_color blue
set --query arghandle_option_deprecation_notice_color || set arghandle_option_deprecation_notice_color red

set --query arghandle_option_default_suffix || set arghandle_option_default_suffix default
set --query arghandle_option_min_suffix || set arghandle_option_min_suffix min
set --query arghandle_option_max_suffix || set arghandle_option_max_suffix max

set --query arghandle_option_usage_max_count || set arghandle_option_usage_max_count 5


function is_int --argument-names value --description 'Check whether a value is an int'
    string match --regex --quiet -- '^-?\d+$' "$value"
end

function is_float --argument-names value --description 'Check whether a value is a float'
    string match --regex --quiet -- '^-?\d+\.\d+$' "$value"
end

function is_bool --argument-names value --description 'Check whether a value is a bool'
    string match --regex --quiet -- '^(true|false)$' "$value"
end

function is_str --argument-names value --description 'Check whether a value is a str'
    not is_int "$value" && not is_float "$value" && not is_bool "$value"
end

function is_nullable_int --argument-names value --description 'Check whether a value is an int or nothing'
    is_int "$value" || test -z "$value"
end

function is_nullable_float --argument-names value --description 'Check whether a value is a float or nothing'
    is_float "$value" || test -z "$value"
end

function is_nullable_bool --argument-names value --description 'Check whether a value is a bool or nothing'
    is_bool "$value" || test -z "$value"
end

function is_simple --argument-names value --description 'Check whether a value is a simple one'
    is_int "$value" || is_float "$value" || is_bool "$value" || is_str "$value" || is_nullable_int "$value" || is_nullable_float "$value" || is_nullable_bool "$value"
end

function is_int_range --argument-names value --description 'Check whether a value is an int range'
    set --local borders (string split -- .. "$value")
    set --local start "$borders[1]"
    set --local end "$borders[2]"

    is_nullable_int "$start" || return
    is_nullable_int "$end" || return
    test -z "$start" && test -z "$end" && return 1

    if test -n "$start" && test -n "$end"
        test "$start" -le "$end"
    end
end

function is_float_range --argument-names value --description 'Check whether a value is a float range'
    set --local borders (string split -- .. "$value")
    set --local start "$borders[1]"
    set --local end "$borders[2]"

    is_nullable_float "$start" || return
    is_nullable_float "$end" || return
    test -z "$start" && test -z "$end" && return 1

    if test -n "$start" && test -n "$end"
        test "$start" -le "$end"
    end
end

function is_range --argument-names value --description 'Check whether a value is a range'
    is_int_range "$value" || is_float_range "$value"
end

function range_start --argument-names value --description 'Get a lowest range value if it exists'
    is_range "$value" && string match --regex -- '^-?\d+(?:\.\d+)?' "$value"
end

function range_end --argument-names value --description 'Get a highest range value if it exists'
    is_range "$value" && string match --regex -- '-?\d+(?:\.\d+)?$' "$value"
end

function are_unique_items --description 'Check whether all items are unique'
    set --local initial_count (count $argv)
    set --local deduplicated_count (count (echo "$argv" | string split -- " " | sort --unique))
    test "$initial_count" -eq "$deduplicated_count"
end

function is_int_enum --argument-names value --description 'Check whether a value is an int enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_int "$item" || return
    end
end

function is_float_enum --argument-names value --description 'Check whether a value is a float enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_float "$item" || return
    end
end

function is_bool_enum --argument-names value --description 'Check whether a value is a bool enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_bool "$item" || return
    end
end

function is_str_enum --argument-names value --description 'Check whether a value is a str enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_str "$item" || return
    end
end

function is_nullable_int_enum --argument-names value --description 'Check whether a value is a nullable int enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_nullable_int "$item" || return
    end
end

function is_nullable_float_enum --argument-names value --description 'Check whether a value is a nullable float enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_nullable_float "$item" || return
    end
end

function is_nullable_bool_enum --argument-names value --description 'Check whether a value is a nullable bool enum'
    set --local items (string split -- , "$value")
    are_unique_items $items || return
    for item in $items
        is_nullable_bool "$item" || return
    end
end

function is_enum --argument-names value --description 'Check whether a value is an enum'
    is_int_enum "$value" || is_float_enum "$value" || is_bool_enum "$value" || is_str_enum "$value" || is_nullable_int_enum "$value" || is_nullable_float_enum "$value" || is_nullable_bool_enum "$value"
end

function is_type --argument-names value --description 'Check whether a value is a type'
    string match --regex --quiet -- '^(int|float|bool|str)$' "$value"
end

function is_short_option --argument-names value --description 'Check whether a value is a short option'
    string match --regex --quiet -- '^-[^- ]$' "$value"
end

function is_long_option --argument-names value --description 'Check whether a value is a long option'
    string match --regex --quiet -- '^--[^- ]{2,}(-[^- ]+)*$' "$value"
end

function is_option --argument-names value --description 'Check whether a value is an option'
    is_short_option "$value" || is_long_option "$value"
end

function is_option_pair --argument-names value --description 'Check whether a value is a short/long option pair'
    set --local items (string split -- / "$value")
    is_short_option "-$items[1]" && is_long_option "--$items[2]"
end

function option_pair_short --argument-names value --description 'Get a short option from a pair'
    is_option_pair "$value" && string replace --regex -- '^(.)/.*$' '$1' "$value"
end

function option_pair_long --argument-names value --description 'Get a long option from a pair'
    is_option_pair "$value" && string replace --regex -- '^./(.*)$' '$1' "$value"
end

function is_this_option --argument-names short_option long_option value --description 'Check whether an option is a specific one'
    is_short_option "-$short_option" || return
    is_long_option "--$long_option" || return
    is_option "$value" || return
    string match --regex --quiet -- "^(-$short_option|--$long_option)\$" "$value"
end

function __arghandle_inferred_type_from_expression --argument-names value --description 'Get an inferred type of a value'
    set --local inferred_type
    if is_int_range "$value"
        set inferred_type int
    else if is_float_range "$value"
        set inferred_type float
    else if is_int_enum "$value"
        set inferred_type int
    else if is_float_enum "$value"
        set inferred_type float
    else if is_bool_enum "$value"
        set inferred_type float
    else if is_str_enum "$value"
        set inferred_type str
    else
        return 1
    end
    echo "$inferred_type"
end

# Used to allow specify either type explicitly or an expression which type is
# inferred from. To use type name as an enum value prepend "@" symbol.
# To add first literal leading "@" symbol duplicate it twice like "@@str" to
# make enum contain "@str" value.
function __arghandle_inferred_type --argument-names value --description 'Get an inferred type of a value'
    if string match --quiet '@*' -- "$value"
        set --local value (string replace --regex -- '^@(.*)$' '$1' "$value")
        inferred_type_from_expression "$value"
        return
    end

    if is_type "$value"
        echo "$value"
        return
    end

    inferred_type_from_expression "$value"
end

function __arghandle_inferred_type_from_contraints --argument-names range enum --description 'Get an inferred option type from --range or --enum options'
    set --local inferred_type str
    if test -n "$range"
        if is_int_range "$range"
            set inferred_type int
        else if is_float_range "$range"
            set inferred_type float
        end
    else if test -n "$enum"
        if is_int_enum "$enum"
            set inferred_type int
        else if is_float_enum "$enum"
            set inferred_type float
        else if is_bool_enum "$enum"
            set inferred_type bool
        else if is_str_enum "$enum"
            set inferred_type str
        end
    else
        return 1
    end

    echo "$inferred_type"
end

function is_in_int_range --argument-names range value --description 'Check whether a value in an int range'
    is_int_range "$range" || return
    is_int "$value" || return

    set --local start (range_start "$range")
    set --local end (range_end "$range")

    if test -n "$start" && test -n "$end"
        test "$start" -le "$value" && test "$end" -ge "$value"
    else if test -n "$start"
        test "$start" -le "$value"
    else if test -n "$end"
        test "$end" -ge "$value"
    end
end

function is_in_float_range --argument-names range value --description 'Check whether a value in an float range'
    is_float_range "$range" || return
    is_float "$value" || return

    set --local start (range_start "$range")
    set --local end (range_end "$range")

    if test -n "$start" && test -n "$end"
        test "$start" -le "$value" && test "$end" -ge "$value"
    else if test -n "$start"
        test "$start" -le "$value"
    else if test -n "$end"
        test "$end" -ge "$value"
    end
end

function is_in_range --argument-names range value --description 'Check whether a value in a range'
    is_in_int_range "$range" "$value" || is_in_float_range "$range" "$value"
end

function is_in_int_enum --argument-names enum value --description 'Check whether a value in an int enum'
    is_int_enum "$enum" || return
    is_int "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" -eq "$value" && return
    end

    return 1
end

function is_in_float_enum --argument-names enum value --description 'Check whether a value in a float enum'
    is_float_enum "$enum" || return
    is_float "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" -eq "$value" && return
    end

    return 1
end

function is_in_bool_enum --argument-names enum value --description 'Check whether a value in a bool enum'
    is_bool_enum "$enum" || return
    is_bool "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" = "$value" && return
    end

    return 1
end

function is_in_str_enum --argument-names enum value --description 'Check whether a value in a str enum'
    is_str_enum "$enum" || return
    is_str "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" = "$value" && return
    end

    return 1
end

function is_in_nullable_int_enum --argument-names enum value --description 'Check whether a value in a nullable int enum'
    is_nullable_int_enum "$enum" || return
    is_nullable_int "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" -eq "$value" && return
    end

    return 1
end

function is_in_nullable_float_enum --argument-names enum value --description 'Check whether a value in a nullable float enum'
    is_nullable_float_enum "$enum" || return
    is_nullable_float "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" -eq "$value" && return
    end

    return 1
end

function is_in_nullable_bool_enum --argument-names enum value --description 'Check whether a value in a nullable bool enum'
    is_nullable_bool_enum "$enum" || return
    is_nullable_bool "$value" || return

    set --local items (string split -- , "$enum")
    for item in $items
        test "$item" = "$value" && return
    end

    return 1
end

function is_in_enum --argument-names enum value --description 'Check whether a value in an enum'
    is_in_int_enum "$enum" "$value" || is_in_float_enum "$enum" "$value" || is_in_bool_enum "$enum" "$value" || is_in_str_enum "$enum" "$value" || is_in_nullable_int_enum "$enum" "$value" || is_in_nullable_float_enum "$enum" "$value" || is_in_nullable_bool_enum "$enum" "$value"
end

function range_to_str --argument-names range --description 'Convert a range to a string'
    is_range "$range" || return

    set --local start (range_start "$range")
    set --local end (range_end "$range")

    set --local str ""
    test -n "$start" && set str "greater than or equal to $start"
    test -n "$start" && test -n "$end" && set str "$str and "
    test -n "$end" && set str $str"less than or equal to $end"

    echo "$str"
end

function enum_to_str --argument-names enum --description 'Convert an enum to a string'
    is_enum "$enum" || return
    echo -n "one of "
    set --local items (string split -- , "$enum")
    set --local count (count $items)

    echo -n "$items[1]"

    set --local index 2
    while test "$index" -lt "$count"
        echo -n ", $items[$index]"
        set index (math "$index" + 1)
    end

    test "$count" -gt 1 && echo -n " and $items[$count]"
end

function range_to_markdown_str --argument-names range --description 'Convert a range to a Markdown string'
    is_range "$range" || return

    set --local start (range_start "$range")
    set --local end (range_end "$range")

    test -z "$start" && set start -infinity
    test -z "$end" && set end infinity

    echo "**range**: `[$start..$end]`"
end

function enum_to_markdown_str --argument-names enum --description 'Convert an enum to a Markdown string'
    is_enum "$enum" || return
    echo -n "**enumeration**: "
    set --local items (string split -- , "$enum")
    set --local count (count $items)

    echo -n "`$items[1]`"

    set --local index 2
    while test "$index" -lt "$count"
        echo -n ", `$items[$index]`"
        set index (math "$index" + 1)
    end

    test "$count" -gt 1 && echo -n " and `$items[$count]`"
end


function __arghandle_error --argument-names expected found
    if test -n "$found"
        set found "'$found'"
    else
        set found nothing
    end

    echo -n (set_color normal)"arghandle: Expected "(set_color green)"$expected" >&2
    echo (set_color normal)", but "(set_color red)"$found"(set_color normal)" found" >&2
end

function __arghandle_in_definition_error --argument-names expected found index
    __arghandle_error "$expected within a $index-th option definition" "$found"
end

function __arghandle_out_of_definition_error --argument-names expected found
    __arghandle_error "$expected before the first option definition" "$found"
end

function __arghandle_missing_option_in_definition_error --argument-names expected_option index
    __arghandle_in_definition_error "'$expected_option' option" "" "$index"
end

function __arghandle_missing_option_out_of_definition_error --argument-names expected_option
    __arghandle_out_of_definition_error "'$expected_option' option"
end

function __arghandle_incorrect_option_in_definition_error --argument-names found index
    __arghandle_in_definition_error "known option" "$found" "$index"
end

function __arghandle_incorrect_option_out_of_definition_error --argument-names found
    __arghandle_out_of_definition_error "known option" "$found"
end

function __arghandle_incorrect_option_value_format_in_definition_error --argument-names expected_option found index expected_format
    __arghandle_in_definition_error "'$expected_option' option to be $expected_format" "$found" "$index"
end

function __arghandle_incorrect_option_value_format_out_of_definition_error --argument-names expected_option found expected_format
    __arghandle_out_of_definition_error "'$expected_option' option to be $expected_format" "$found"
end

function __arghandle_incorrect_option_range_value_format_in_definition_error --argument-names expected_option found index
    __arghandle_incorrect_option_value_format_in_definition_error "$expected_option" "$found" "$index" "{{from}}..{{to}} (both numbers can't be missing at the same time)"
end

function __arghandle_incorrect_option_range_value_format_out_of_definition_error --argument-names expected_option found
    __arghandle_incorrect_option_value_format_out_of_definition_error "$expected_option" "$found" "{{from}}..{{to}} (both numbers can't be missing at the same time)"
end

function __arghandle_incorrect_option_enum_value_format_in_definition_error --argument-names expected_option found index
    __arghandle_incorrect_option_value_format_in_definition_error "$expected_option" "$found" "$index" "{{item1}},{{item2}},... (leading and trailing spaces are prohibited and unique values expected)"
end

function __arghandle_incorrect_option_enum_value_format_out_of_definition_error --argument-names expected_option found
    __arghandle_incorrect_option_value_format_out_of_definition_error "$expected_option" "$found" "{{item1}},{{item2}},... (leading and trailing spaces are prohibited and unique values expected)"
end

function __arghandle_incorrect_option_empty_value_format_in_definition_error --argument-names expected_option index
    __arghandle_incorrect_option_value_format_in_definition_error "$expected_option" "" "$index" "non-empty string"
end

function __arghandle_incorrect_option_empty_value_format_out_of_definition_error --argument-names expected_option
    __arghandle_incorrect_option_value_format_out_of_definition_error "$expected_option" "" "non-empty string"
end

function __arghandle_duplicate_option_in_definition_error --argument-names option
    __arghandle_error "unique '$option' option arguments within option definitions" "duplicating option values"
end

function __arghandle_hint --argument-names hint
    set --local hint (string replace --all --regex -- '(-[^\'" ]+)' (set_color "$arghandle_option_color")'$1'(set_color green) "$hint")
    echo -e (set_color normal)"arghandle: Check whether "(set_color green)"$hint"(set_color normal) >&2
end

function __arghandle_color --argument-names description variable
    echo (set_color "$$variable")"- [x] This is "(set_color --underline)"$description"(set_color normal)(set_color "$$variable")\
" color "(set_color --background "$$variable")"  "(set_color normal)(set_color "$$variable")" ("(set_color --bold)\
"\$$variable"(set_color normal)(set_color "$$variable")" variable controls it)" >&2
end

function arghandle_colors --description 'Print colors used by arghandle'
    echo (set_color normal)"The following variables control how helps are generated:" >&2
    __arghandle_color "a title" arghandle_title_color
    __arghandle_color "an --option" arghandle_option_color
    __arghandle_color "an option [m]nemonic" arghandle_option_mnemonic_color
    __arghandle_color "an option [d]efault" arghandle_option_default_color
    __arghandle_color "an option deprecation notice" arghandle_option_deprecation_notice_color
end

function __arghandle_suffix --argument-names description variable
    echo (set_color normal)"- [x] '"(set_color green)$$variable(set_color normal)"' is "(set_color --underline)\
$description(set_color normal)" value suffix ("\
(set_color --bold)"\$$variable"(set_color normal)(set_color normal)" variable controls it)" >&2
end

function arghandle_suffixes --description 'Print suffixes used by arghandle'
    echo (set_color normal)"The following variables control how descriptions are generated for completions:" >&2
    __arghandle_suffix "a default" arghandle_option_default_suffix
    __arghandle_suffix "a minimum" arghandle_option_min_suffix
    __arghandle_suffix "a maximum" arghandle_option_max_suffix
end

function arghandle_settings --description 'Print colors and suffixes used by arghandle'
    arghandle_colors
    echo >&2
    arghandle_suffixes
end


# Options in the form of '-o/--option' are highlighted with $arghandle_option_color.
function __arghandle_description --argument-names description --description 'The first line of help'
    set --local description (string replace --all --regex -- '(-\S[|]--\S{2,})' (set_color "$arghandle_option_color")'$1'(set_color normal) "$description")
    echo -e (set_color normal)"$description."
end

function __arghandle_color_placeholder --argument-names usage type --description 'Colorize placeholders of a specific type'
    set --local variable "arghandle_"$type"_placeholder_color"
    string replace --all --regex -- "\{\{([^{}() ]+) \($type\)\}\}" (set_color --bold "$$variable")'{{$1}}'(set_color normal) "$usage"
end

# Options in the form of '-o|--option' and placeholders are highlighted.
function __arghandle_usage --argument-names usage --description "Usage inside 'Usage' section"
    set --local usage (string replace --all --regex -- '(-[^\[\] =][/|]--[^\[\] =]{2,})' (set_color "$arghandle_option_color")'$1'(set_color normal) "$usage")
    set --local usage (__arghandle_color_placeholder "$usage" int)
    set --local usage (__arghandle_color_placeholder "$usage" float)
    set --local usage (__arghandle_color_placeholder "$usage" bool)
    set --local usage (__arghandle_color_placeholder "$usage" str)
    echo -e (set_color normal)"  $usage"
end

# Titles are highlighted with $arghandle_title_color.
function __arghandle_title --argument-names title --description 'Section title'
    echo -e (set_color "$arghandle_title_color")"$title"(set_color normal)':'
end

# Options are highlighted with $arghandle_option_color.
# Mnemonics (square brackets with letters) are highlighted with $arghandle_option_mnemonic_color. They are used to explain
#   what short options stand for.
function __arghandle_option --argument-names short long description default --description "Option description inside 'Options' section"
    set --local description (string replace --all --regex -- '(\[[^][ ]\])' (set_color "$arghandle_option_mnemonic_color")'$1'(set_color normal) "$description")
    echo -n -e "  "(set_color "$arghandle_option_color")"-$short --$long"(set_color normal)"  $description"
    test -n "$default" && echo -n " [default: "(set_color $arghandle_option_default_color)$default(set_color normal)"]"
    echo .
end

function __arghandle_separator --description 'Section separator'
    echo
end

function __arghandle_markdown_title --argument-names title --description 'Section title'
    echo -e (set_color normal)"# $title"
end

function __arghandle_markdown_usage --argument-names usage --description "Usage inside 'Usage' section"
    set --local usage (string replace --all --regex -- '(-[^\[\] =][/|]--[^\[\] =]{2,})' '`$1`' "$usage")
    echo -e (set_color normal)"$usage."
end

function __arghandle_markdown_option --argument-names short long description default range enum --description "Option description inside 'Options' section"
    echo -n -e "- `-$short`|`--$long`: $description"
    if test -n "$default" || test -n "$range" || test -n "$enum"
        echo -n " ["
        set --local constraints
        test -n "$default" && set --append constraints "**default**: `$default`"
        test -n "$range" && set --append constraints (range_to_markdown_str "$range")
        test -n "$enum" && set --append constraints (enum_to_markdown_str "$enum")
        echo -n (string join ", " $constraints)
        echo -n "]"
    end
    echo .
end

function __arghandle_markdown_separator --description 'Section separator'
    echo
end

function __arghandle_is_non_negative_int --argument-names value
    string match --regex --quiet -- '^\d+$' "$value"
end

function __arghandle_check_short_options --description 'Check $short_options'
    set --local index 1
    set --local count (count $argv)

    while test "$index" -le "$count"
        set --local short_option "$argv[$index]"

        if test -z "$short_option"
            __arghandle_missing_option_in_definition_error --short "$index"
            return 1
        end
        if test (string length "$short_option") -ne 1
            __arghandle_incorrect_option_value_format_in_definition_error --short "$short_option" "$index" "1 character long"
            return 1
        end

        set index (math "$index" + 1)
    end
end

function __arghandle_check_long_options --description 'Check $long_options'
    set --local index 1
    set --local count (count $argv)

    while test "$index" -le "$count"
        set --local long_option "$argv[$index]"

        if test -z "$long_option"
            __arghandle_missing_option_in_definition_error --long "$index"
            return 1
        end
        if test (string length "$long_option") -lt 2
            __arghandle_incorrect_option_value_format_in_definition_error --long "$long_option" "$index" "at least 2 characters long"
            return 1
        end

        set index (math "$index" + 1)
    end
end

function __arghandle_check_options_description --description 'Check $options_description'
    set --local index 1
    set --local count (count $argv)

    while test "$index" -le "$count"
        set --local option_description "$argv[$index]"

        if test -z "$option_description"
            __arghandle_missing_option_in_definition_error --description "$index"
            return 1
        end

        set index (math "$index" + 1)
    end
end

function __arghandle_check_options_range --description 'Check $options_range'
    set --local index 1
    set --local count (count $argv)

    while test "$index" -le "$count"
        set --local option_range "$argv[$index]"

        if test -n "$option_range" && not is_range "$option_range"
            __arghandle_incorrect_option_range_value_format_in_definition_error --range "$option_range" "$index"
            return 1
        end

        set index (math "$index" + 1)
    end
end

function __arghandle_check_options_enum --description 'Check $options_enum'
    set --local index 1
    set --local count (count $argv)

    while test "$index" -le "$count"
        set --local option_enum "$argv[$index]"

        if test -n "$option_enum" && not is_enum "$option_enum"
            __arghandle_incorrect_option_enum_value_format_in_definition_error --enum "$option_enum" "$index"
            return 1
        end

        set index (math "$index" + 1)
    end
end

function __arghandle_check_options_type --description 'Check $options_type'
    set --local index 1
    set --local count (count $argv)

    while test "$index" -le "$count"
        set --local option_type "$argv[$index]"

        if test -n "$option_type" && not is_type "$option_type"
            __arghandle_incorrect_option_value_format_in_definition_error --type "$option_type" "$index" (enum_to_str "str,int,float,bool")
            return 1
        end

        set index (math "$index" + 1)
    end
end

function arghandle --description 'Parses arguments and provides automatically generated help available via -h|--help'
    set --local name
    set --local description
    set --local exclusive
    set --local min_args
    set --local max_args

    set --local short_options
    set --local long_options
    set --local options_description
    set --local options_is_flag
    set --local options_type
    set --local options_range
    set --local options_enum
    set --local options_validator
    set --local options_default

    set --local options_default_specified

    set --local get_completion
    set --local get_snippet_for
    set --local get_markdown

    if is_this_option h help "$argv[1]"
        __arghandle_description "Parses arguments and provides automatically generated help available via -h|--help"
        __arghandle_separator
        __arghandle_title Usage
        __arghandle_usage "arghandle [-n|--name {{value (str)}}] [-d|--description {{value (str)}}] [-e|--exclusive {{value (str)}}] [-m|--min-args {{value (int)}}] [-M|--max-args {{value (int)}}] {{option ...}}"
        __arghandle_separator
        __arghandle_title Options
        __arghandle_option h help "Print [h]elp, to work must be the first option outside of square brackets"
        __arghandle_option n name "Specify a [n]ame of a command for error messages (required)"
        __arghandle_option d description "Specify a [d]escription of a command for -h/--help (required)"
        __arghandle_option e exclusive "Specify [e]xclusive options from option definitions"
        __arghandle_option m min-args "Specify a [m]inimum amount of positional arguments" 0
        __arghandle_option M max-args "Specify a [M]aximum amount of positional arguments" infinity
        __arghandle_option c completion "Get a [c]ompletion code instead of one for parsing arguments"
        __arghandle_option s snippet "Get a [s]nippet code instead of one for parsing arguments, must be one of: code (Visual Studio Code)"
        __arghandle_option a markdown "Get a m[a]rkdown code instead of one for parsing arguments"
        __arghandle_option d description "Specify an option [d]escription"
        __arghandle_option s short "Specify a [s]hort variant of an option"
        __arghandle_option l long "Specify a [l]ong variant of an option"
        __arghandle_option f flag "Specify whether an option is [f]lag and doesn't accept any argument"
        __arghandle_option t type "Specify a value [t]ype of an option, must be one of: str, int, float, bool"
        __arghandle_option R range "Specify a valid value [R]ange of an option as a number range"
        __arghandle_option e enum "Specify a valid value of an option as an [e]num"
        __arghandle_option v validator "Specify a value [v]alidator of an option as a call to a function"
        __arghandle_option d default "Specify a [d]efault value of an option"
        return
    end

    set --local index 1

    while set --query "argv[$index]" && not string match --regex --quiet -- '^(\[|\]|:)$' "$argv[$index]"
        set --local option "$argv[$index]"
        set --local argument $argv[(math $index + 1)]

        switch "$option"
            case -n
                set name "$argument"
            case --name
                set name "$argument"
            case -d
                set description "$argument"
            case --description
                set description "$argument"
            case -e
                set --append exclusive "$argument"
            case --exclusive
                set --append exclusive "$argument"
            case -m
                set min_args "$argument"
            case --min-args
                set min_args "$argument"
            case -M
                set max_args "$argument"
            case --max-args
                set max_args "$argument"
            case -c
                set get_completion true
            case --completion
                set get_completion true
            case -s
                set get_snippet_for "$argument"
            case --snippet
                set get_snippet_for "$argument"
            case -a
                set get_markdown true
            case --markdown
                set get_markdown true
            case '*'
                __arghandle_incorrect_option_out_of_definition_error "$option"
                return 1
        end

        not is_this_option c completion "$option" && not is_this_option a markdown "$option"
        set --local requires_argument "$status"
        test "$requires_argument" -eq 0 && set index (math "$index" + 1)

        set index (math "$index" + 1)
    end

    if test -z "$name"
        __arghandle_incorrect_option_empty_value_format_out_of_definition_error --name
        return 1
    end
    if test -z "$description"
        __arghandle_incorrect_option_empty_value_format_out_of_definition_error --description
        return 1
    end
    if test -n "$min_args" && not __arghandle_is_non_negative_int "$min_args"
        __arghandle_incorrect_option_value_format_out_of_definition_error --min-args "$min_args" 'non-negative integer'
        return 1
    end
    if test -n "$max_args" && not __arghandle_is_non_negative_int "$max_args"
        __arghandle_incorrect_option_value_format_out_of_definition_error --max-args "$max_args" 'non-negative integer'
        return 1
    end
    if test -n "$min_args" && test -n "$max_args" && test "$min_args" -gt "$max_args"
        __arghandle_out_of_definition_error "'--min-args' be less than or equal to '--max-args'" "--min-args = $min_args and --max-args = $max_args"
        return 1
    end
    if test -n "$get_snippet_for" && not is_in_str_enum code "$get_snippet_for"
        __arghandle_out_of_definition_error "--snippet to be one of code" "$get_snippet_for"
        return 1
    end

    set --local exclusive_index 1
    while test "$exclusive_index" -le (count $exclusive)
        if test -n "$exclusive[$exclusive_index]" && not is_enum "$exclusive[$exclusive_index]"
            __arghandle_incorrect_option_enum_value_format_out_of_definition_error "--exclusive ($exclusive_index-th instance)" "$exclusive[$exclusive_index]"
            return 1
        end
        set exclusive_index (math "$exclusive_index" + 1)
    end

    if test "$argv[$index]" = ":"
        set --local expanded_argv
        set --local source_index 1

        while test "$source_index" -lt "$index"
            set --append expanded_argv "$argv[$source_index]"
            set source_index (math "$source_index" + 1)
        end

        set --append expanded_argv "["
        set source_index (math "$source_index" + 1)

        set --local expanded_option_definition_count 1
        while set --query "argv[$source_index]"
            set --local option_type "$argv[$source_index]"
            set --local option_pair $argv[(math "$source_index" + 1)]
            set --local option_description $argv[(math "$source_index" + 2)]

            if test -z "$option_type"
                __arghandle_in_definition_error "type to be "(enum_to_str "str,int,float,bool,range,enum")" (type is inferred in the last two cases)" "$option_type" "$expanded_option_definition_count"
                return 1
            end
            if test -n "$option_pair" && not is_option_pair "$option_pair"
                __arghandle_in_definition_error "option pair to be {{short-option}}/{{long-option}} (leading dashes are prohibited)" "$option_pair" "$expanded_option_definition_count"
                return 1
            end
            if test -z "$option_description"
                __arghandle_in_definition_error "option description to be non-empty string" "" "$expanded_option_definition_count"
                return 1
            end

            set --append expanded_argv --short (option_pair_short "$option_pair")
            set --append expanded_argv --long (option_pair_long "$option_pair")
            set --append expanded_argv --description "$option_description"
            set --append expanded_argv --type (__arghandle_inferred_type "$option_type")

            if not is_type "$option_type"
                if is_range "$option_type"
                    set --append expanded_argv --range "$option_type"
                else if is_enum "$option_type"
                    set --append expanded_argv --enum "$option_type"
                end
            end

            set --append expanded_argv "]" "["

            set source_index (math "$source_index" + 3)
            set expanded_option_definition_count (math "$expanded_option_definition_count" + 1)
        end

        set --erase expanded_argv[(count $expanded_argv)]

        set --erase argv
        set --erase argv # bug: for some reason it is required to properly clear $argv
        set source_index 1
        while test "$source_index" -le (count $expanded_argv)
            set argv[$source_index] "$expanded_argv[$source_index]"
            set source_index (math "$source_index" + 1)
        end

        echo -n (set_color normal)"arghandle: arguments expanded to " >&2
        echo (set_color yellow)(string escape -- $argv)(set_color normal) >&2
    end

    set --local option_index 1

    while set --query "argv[$index]"
        if test "$argv[$index]" != "["
            __arghandle_error "'[' before the $option_index-th pending option definition" "$argv[$index]"
            return 1
        end
        set index (math "$index" + 1)
        while set --query "argv[$index]" && test "$argv[$index]" != "]"
            set --local option "$argv[$index]"
            set --local argument $argv[(math $index + 1)]

            if test "$option" = "["
                __arghandle_in_definition_error option "$option" "$option_index"
                __arghandle_hint "options accept correct arguments; this is incorrect: [ --range ] (no correct '--range' argument and missing closing ']')"
                return 1
            end

            switch "$option"
                case -s
                    set short_options[$option_index] "$argument"
                case --short
                    set short_options[$option_index] "$argument"
                case -l
                    set long_options[$option_index] "$argument"
                case --long
                    set long_options[$option_index] "$argument"
                case -d
                    set options_description[$option_index] "$argument"
                case --description
                    set options_description[$option_index] "$argument"
                case -f
                    set options_is_flag[$option_index] true
                case --flag
                    set options_is_flag[$option_index] true
                case -t
                    set options_type[$option_index] "$argument"
                case --type
                    set options_type[$option_index] "$argument"
                case -R
                    set options_range[$option_index] "$argument"
                case --range
                    set options_range[$option_index] "$argument"
                case -e
                    set options_enum[$option_index] "$argument"
                case --enum
                    set options_enum[$option_index] "$argument"
                case -v
                    set options_validator[$option_index] "$argument"
                case --validator
                    set options_validator[$option_index] "$argument"
                case -d
                    set options_default[$option_index] "$argument"
                    set options_default_specified[$option_index] true
                case --default
                    set options_default[$option_index] "$argument"
                    set options_default_specified[$option_index] true
                case '*'
                    __arghandle_incorrect_option_in_definition_error "$option" "$option_index"
                    return 1
            end

            not is_this_option f flag "$option"
            set --local requires_argument "$status"
            if test "$requires_argument" -eq 0 && not set --query argument
                __arghandle_incorrect_option_empty_value_format_in_definition_error "$option" "$option_index"
                return 1
            end

            set index (math "$index" + 1)
            test "$requires_argument" -eq 0 && set index (math "$index" + 1)
        end

        if test "$argv[$index]" != ']'
            __arghandle_error "']' after $option_index-th option definition"
            return 1
        end

        set index (math "$index" + 1)
        set option_index (math "$option_index" + 1)
    end

    # Independent checks are done via function calls.
    __arghandle_check_short_options $short_options || return
    __arghandle_check_long_options $long_options || return
    __arghandle_check_options_description $options_description || return
    __arghandle_check_options_range $options_range || return
    __arghandle_check_options_enum $options_enum || return
    __arghandle_check_options_type $options_type || return

    set index 1
    while test "$index" -lt "$option_index"
        set --local short_option "$short_options[$index]"
        set --local long_option "$long_options[$index]"
        set --local option_description "$options_description[$index]"

        set --local option_range "$options_range[$index]"
        set --local option_enum "$options_enum[$index]"
        set --local option_type "$options_type[$index]"

        set --local inferred_type (__arghandle_inferred_type_from_contraints "$option_range" "$option_enum")
        test -n "$option_range" || test -n "$option_enum"
        set --local at_least_one_contrains_set "$status"
        if test "$at_least_one_contrains_set" -eq 0
            if test -n "$option_type" && test "$option_type" != "$inferred_type"
                __arghandle_in_definition_error "'--type' equal to '$inferred_type' type" "--type = $option_type and inferred type = $inferred_type" "$index"
                return 1
            end

            set options_type[$index] "$inferred_type"
        else
            test -z "$option_type" && set options_type[$index] str
        end

        set option_type "$options_type[$index]"
        set --local option_is_flag "$options_is_flag[$index]"
        set --local option_default "$options_default[$index]"
        set --local option_default_specified "$options_default_specified[$index]"

        if test -n "$option_is_flag" && test -n "$option_default_specified"
            __arghandle_in_definition_error "either '--flag' or '--default' options" "both options" "$index"
            return 1
        end

        if test -n "$option_default_specified"
            set --local inferred_type (__arghandle_inferred_type_from_expression "$option_default")
            if test "$option_type" != "$inferred_type"
                __arghandle_in_definition_error "'--default' type equal to '$option_type\
' type" "--type = $option_type and --default type = $inferred_type" "$index"
                return 1
            end
        end

        set index (math $index + 1)
    end

    if test (count $short_options) -ne (count (echo $short_options | string split " " | sort --unique))
        __arghandle_duplicate_option_in_definition_error --short
        return 1
    end
    if test (count $long_options) -ne (count (echo $long_options | string split " " | sort --unique))
        __arghandle_duplicate_option_in_definition_error --long
        return 1
    end

    if test -n "$get_completion"
        echo complete --erase "$name" ";"
        echo complete --command "$name" --short-option h --long-option help --description "'Show help'" ";"

        set index 1
        while test "$index" -lt "$option_index"
            set --local short_option "$short_options[$index]"
            set --local long_option "$long_options[$index]"
            set --local option_description "$options_description[$index]"
            set --local option_range "$options_range[$index]"
            set --local option_enum "$options_enum[$index]"
            set --local option_default_specified "$options_default_specified[$index]"
            set --local option_default "$options_default[$index]"

            echo -n complete --command "$name" --short-option "$short_option" --long-option "$long_option" --description \
                (string escape -- "$option_description")" "

            set --local raw_start (range_start "$option_range")
            set --local raw_end (range_end "$option_range")

            set --local arguments ""

            test -n "$option_default_specified" && test "$option_default" != "$raw_start" && test "$option_default" != "$raw_end" \
                set arguments "$option_default\t$arghandle_option_default_suffix"

            set --local min_suffix "$arghandle_option_min_suffix"
            test "$option_default" = "$raw_start" && set min_suffix "$arghandle_option_default_suffix-$arghandle_option_min_suffix"

            set --local max_suffix "$arghandle_option_max_suffix"
            test "$option_default" = "$raw_end" && set max_suffix "$arghandle_option_default_suffix-$arghandle_option_max_suffix"

            set --local start "$raw_start\t$min_suffix"
            set --local end "$raw_end\t$max_suffix"
            test -n "$option_range" && set arguments "$arguments $start $end"

            if test -n "$option_enum"
                set --local items (string split -- , "$option_enum")
                for item in $items
                    set arguments "$arguments $item"
                end
            end

            set arguments (string replace --regex --all -- '^\s+|\s+$' '' $arguments)
            test -n "$arguments" && echo -n --arguments (string escape -- "$arguments")" "
            echo ";"

            set index (math "$index" + 1)
        end
        return
    else if test -n "$get_snippet_for"
        switch "$get_snippet_for"
            case code
                set --local body "$name"

                set --local index 1
                set --local placeholder_index 1
                while test "$index" -lt "$option_index"
                    if test -n "$option_is_flag"
                        set index (math "$index" + 1)
                        continue
                    end

                    set --local short_option "$short_options[$index]"
                    set --local long_option "$long_options[$index]"
                    set --local option_description "$options_description[$index]"

                    set --local placeholder_value_index (math "$placeholder_index" + 1)
                    set body "$body \${$placeholder_index|--$long_option,-$short_option|} \${$placeholder_value_index:"(string escape -- "$option_description")"}"

                    set index (math "$index" + 1)
                    set placeholder_index (math "$placeholder_index" + 2)
                end

                jq '{ ($id): { prefix: $prefix, description: $description, body: $body } }' --monochrome-output --null-input \
                    --arg id "$name" \
                    --arg prefix "$name" \
                    --arg description "$description" \
                    --arg body "$body"
        end
        return
    else if test -n "$get_markdown"
        __arghandle_markdown_title "`$name` function"
        __arghandle_markdown_usage "$description"
        __arghandle_markdown_separator

        __arghandle_markdown_title Options
        __arghandle_markdown_option h help 'Print [h]elp'

        set index 1
        while test "$index" -lt "$option_index"
            set --local short_option "$short_options[$index]"
            set --local long_option "$long_options[$index]"
            set --local option_description "$options_description[$index]"
            set --local option_default "$options_default[$index]"
            set --local option_range "$options_range[$index]"
            set --local option_enum "$options_enum[$index]"

            __arghandle_markdown_option "$short_option" "$long_option" "$option_description" \
                "$option_default" "$option_range" "$option_enum"

            set index (math "$index" + 1)
        end
        return
    end

    set --local generated_option_specification h/help
    set index 1
    while test "$index" -lt "$option_index"
        set --local option_is_flag "$options_is_flag[$index]"
        set --local option_specification "$short_options[$index]/$long_options[$index]"

        if test -z "$option_is_flag"
            set option_specification "$option_specification="

            set --local option_type "$options_type[$index]"
            set --local option_range "$options_range[$index]"
            set --local option_enum "$options_enum[$index]"

            set option_specification "$option_specification! "

            if test -n "$option_range"
                set option_specification $option_specification"is_in_range \"$option_range\" \"\$_flag_value\""
            else if test -n "$option_enum"
                set option_specification $option_specification"is_in_enum \"$option_enum\" \"\$_flag_value\""
            else
                set option_specification $option_specification"test (__arghandle_inferred_type_from_expression \"\$_flag_value\" || echo \"str\") = $option_type"
            end
        end

        set --append generated_option_specification (string escape -- "$option_specification")

        set index (math "$index" + 1)
    end

    set --local parse_command "$generated_option_specification"
    if set --query exclusive
        for item in $exclusive
            set --prepend parse_command --exclusive "$item"
        end
    end

    test -n "$max_args" && set --prepend parse_command --max-args "$max_args"
    test -n "$min_args" && set --prepend parse_command --min-args "$min_args"

    set --local options_usage "{{option ...}}"

    if test (math $option_index - 1) -le "$arghandle_option_usage_max_count"
        set options_usage
        set --local index 1
        while test "$index" -lt "$option_index"
            set --local option_is_flag "$options_is_flag[$index]"
            set --local short_option "$short_options[$index]"
            set --local long_option "$long_options[$index]"
            set --local option_type "$options_type[$index]"
            set --local option_default_specified "$options_default_specified[$index]"

            set --local option_usage ""

            test -n "$option_default_specified" && set option_usage "["
            set option_usage "$option_usage-$short_option|--$long_option"
            test -z "$option_is_flag" && set option_usage "$option_usage={{value ($option_type)}}"
            test -n "$option_default_specified" && set option_usage "$option_usage]"

            set --append options_usage "$option_usage"

            set index (math "$index" + 1)
        end
    end

    set --prepend options_usage "[-h|--help]"

    echo argparse --name "$name" "$parse_command" -- '$argv' "||" return ";"
    echo if set --query _flag_h ";"
    echo __arghandle_description (string escape "$description") ";"
    echo __arghandle_separator ";"
    echo __arghandle_title Usage ";"
    echo __arghandle_usage (string escape "$name $options_usage") ";"
    echo __arghandle_separator ";"
    echo __arghandle_title Options ";"

    echo __arghandle_option h help "'Print [h]elp'" ";"

    set index 1
    while test "$index" -lt "$option_index"
        echo __arghandle_option "$short_options[$index]" "$long_options[$index]" \
            (string escape "$options_description[$index]") (string escape "$options_default[$index]") ";"
        set index (math "$index" + 1)
    end

    echo return ";"
    echo end ";"

    set index 1
    while test "$index" -lt "$option_index"
        set --local option_is_flag "$options_is_flag[$index]"
        set --local option_default "$options_default[$index]"
        set --local option_default_specified "$options_default_specified[$index]"
        set --local short_option "$short_options[$index]"
        set --local long_option "$long_options[$index]"
        set --local option_variable "_flag_$long_option"

        if test -n "$option_is_flag"
            set index (math "$index" + 1)
            continue
        end

        if test -n "$option_default_specified"
            echo not set --query "$option_variable" "&&" set "$option_variable" (string escape -- "$option_default") ";"
        else
            echo if not set --query "$option_variable" ";"
            echo echo "$name: Missing option -$short_option/--$long_option" ">&2" ";"
            echo return 1 ";"
            echo end ";"
        end
        set index (math "$index" + 1)
    end
end

function arg_parse --description 'Call arghandle without any additional options added'
    if test -n "$arghandle_suppress_errors"
        arghandle $argv 2>/dev/null
    else
        arghandle $argv
    end
end

function arg_completion --description 'Call arghandle with --complete option prepended'
    if test -n "$arghandle_suppress_errors"
        arghandle --completion $argv 2>/dev/null
    else
        arghandle --completion $argv
    end
end

function arg_snippet --description 'Call arghandle with --snippet option prepended'
    if test -n "$arghandle_suppress_errors"
        arghandle --snippet $argv[1] $argv[2..] 2>/dev/null
    else
        arghandle --snippet $argv[1] $argv[2..]
    end
end

function arg_markdown --description 'Call arghandle with --markdown option prepended'
    if test -n "$arghandle_suppress_errors"
        arghandle --markdown $argv 2>/dev/null
    else
        arghandle --markdown $argv
    end
end


complete --command arghandle --long-option help --description "Print [h]elp"
complete --command arghandle --long-option name --exclusive --description "Specify a [n]ame of a command for error messages"
complete --command arghandle --long-option description --exclusive --description "Specify a [d]escription of a command for -h|--help OR for an option"
complete --command arghandle --long-option exclusive --exclusive --description "Specify [e]xclusive options from option definitions"
complete --command arghandle --long-option min-args --exclusive --arguments "0\t$arghandle_option_default_suffix" --description "Specify a [m]inimum amount of positional arguments"
complete --command arghandle --long-option max-args --exclusive --description "Specify a [M]aximum amount of positional arguments"
complete --command arghandle --long-option completion --exclusive --description "Get a [c]ompletion code instead of one for parsing arguments"
complete --command arghandle --long-option snippet --exclusive --arguments code --description "Get a [s]nippet code instead of one for parsing arguments"
complete --command arghandle --long-option markdown --exclusive --arguments code --description "Get a m[a]rkdown code instead of one for parsing arguments"
complete --command arghandle --long-option short --exclusive --description "Specify a [s]hort variant of an option"
complete --command arghandle --long-option long --exclusive --description "Specify a [l]ong variant of an option"
complete --command arghandle --long-option flag --description "Specify whether an option is [f]lag and doesn't accept any argument"
complete --command arghandle --long-option type --exclusive --arguments "int\t'An integer' float\t'A float' bool\t'A boolean' str\t'A string'" --description "Specify a value [t]ype of an option"
complete --command arghandle --long-option range --exclusive --description "Specify a valid value [R]ange of an option as a number range"
complete --command arghandle --long-option enum --exclusive --description "Specify a valid value of an option as an [e]num"
complete --command arghandle --long-option default --exclusive --description "Specify a [d]efault value of an option"
complete --command arghandle --arguments ":\t'Start option definitions in a simplified syntax' [\t'Start an option definition in a comprehensive syntax' ]\t'End an option definition in a comprehensive syntax'"

complete --command arg_parse --wraps arghandle
complete --command arg_completion --wraps arghandle
complete --command arg_snippet --wraps arghandle
complete --command arg_markdown --wraps arghandle
