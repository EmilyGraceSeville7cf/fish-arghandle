# Argument handler

Parses arguments, provides automatically generated help available via
`-h`|`--help`, generates completions and snippets. Under the hood it generates a
code to do all this stuff, that is why to make it work argument handler
(`arghandle` function) should be wrapped in `eval`:

```fish
eval (arghandle {{option ...}})
```

## Pros and cons

- :white_check_mark: One option specification for all kind of things like
  help, completions and snippets.
- :white_check_mark: Better type-safety, no need to check whether some
  argument in a specific range/enum or of some type manually.
- :negative_squared_cross_mark: Syntax may be more complicated than for
  `argparse` and `complete`, but we are working on improving it.

## Introduction example

Simplified syntax:

```fish
source ./arghandle.fish

# Option specification with a simple syntax.
# All options for "search_book" functions are described after a colon (:) in the following form:
# {{type}} {{short_option}}/{{long_option}} {{description}}
# Mnemonics in square brackets are used to help users memorize short options.
set __search_book_option_specification \
    --name search_book --description 'Function to search books in an online book store' : \
    # --author|-a option should be an arbitrary string
    str a/author 'A book [a]uthor to search' \
    # --book|-b option should be an arbitrary string
    str b/book 'A [b]ook to search' \
    # --from|-f option should be an arbitrary integer
    int f/from 'A book page to show [f]rom' \
    # --to|-t option should be an arbitrary integer
    int t/to 'A book page to show up [t]o'
    
function search_book
    # Evaluate all arguments, and use them as with "argparse" below.
    # "2> /dev/null" is appended to the end to hide a note about how "arghandle" arguments are interpreted.
    eval (arghandle $__search_book_option_specification 2> /dev/null)
    # Options are available as "$_flag_{{flag_name}}".
    echo "Searching book '$_flag_book' written by '$_flag_author' to show $_flag_from..$_flag_to pages..."
end

# Get the completion for "search_book" function.
# "2> /dev/null" is appended to the end to hide a note about how "arghandle" arguments are interpreted.
eval (arghandle --completion $__search_book_option_specification 2> /dev/null)

# Call function as it's done with "argparse".
search_book --book="Little women" --author="Louisa May Alcott" --from=1 --to=30
```

Comprehensive syntax:

```fish
source ./arghandle.fish

# Option specification with a simple syntax.
# All options for "search_book" functions are described in the following form:
# [ --description {{description}} --short {{short_option}} --long {{long_option}} --type {{type}} ]
# Mnemonics in square brackets are used to help users memorize short options.
set __search_book_option_specification \
    --name search_book --description 'Function to search books in an online book store' \
    # --author|-a option should be an arbitrary string
    [ --description 'A book [a]uthor to search' --short a --long author --type str ] \
    # --book|-b option should be an arbitrary string
    [ --description 'A [b]ook to search' --short b --long book --type str ] \
    # --from|-f option shoold be an arbitrary integer
    [ --description 'A book page to show [f]rom' --short f --long from --type int ] \
    # --to|-t option should be an arbitrary integer
    [ --description 'A book page to show up [t]o' --short t --long to --type int ]
    
function search_book
    # Evaluate all arguments, and use them as with "argparse" below.
    # "2> /dev/null" is appended to the end to hide a note about how "arghandle" arguments are interpreted.
    eval (arghandle $__search_book_option_specification 2> /dev/null)
    # Options are available as "$_flag_{{flag_name}}".
    echo "Searching book '$_flag_book' written by '$_flag_author' to show $_flag_from..$_flag_to pages..."
end

# Get the completion for "search_book" function.
# "2> /dev/null" is appended to the end to hide a note about how "arghandle" arguments are interpreted.
eval (arghandle --completion $__search_book_option_specification 2> /dev/null)

# Call function as it's done with "argparse".
search_book --book="Little women" --author="Louisa May Alcott" --from=1 --to=30
```

The latter syntax allows provide more details about each available option,
like its default value.

While `arghandle` parses incoming arguments for `search_book` and prints
automatically generated help:

```text
Function to search books in an online book store.

Usage:
  search_book -a|--author={{value}} -b|--book={{value}} -f|--from={{value}} -t|--to={{value}}

Options:
  -a --author  A book [a]uthor to search.
  -b --book  A [b]ook to search.
  -f --from  A book page to show [f]rom.
  -t --to  A book page to show up [t]o.
```

when requested with `--help`|`-h` option it also provides completion (requested
with `--completion`|`-c` option):

```fish
complete --command search_book --short-option h --long-option help --description 'Show help' ;
complete --command search_book --short-option a --long-option author --description 'A book [a]uthor to search' ;
complete --command search_book --short-option b --long-option book --description 'A [b]ook to search' ;
complete --command search_book --short-option f --long-option from --description 'A book page to show [f]rom' ;
complete --command search_book --short-option t --long-option to --description 'A book page to show up [t]o' ;
```

and snippet (requested with `--snippet`|`-s` option):

```json
{
  "search_book": {
    "prefix": "search_book",
    "description": "Function to search books in an online book store",
    "body": "search_book ${1|--author,-a|} ${2:'A book [a]uthor to search'} ${3|--book,-b|} ${4:'A [b]ook to search'} ${5|--from,-f|} ${6:'A book page to show [f]rom'} ${7|--to,-t|} ${8:'A book page to show up [t]o'}"
  }
}
```

## Syntax

```fish
__arghandle_usage 'arghandle {{option ...}} {{option_definition ...}}'
```

### Options (`{{option ...}}`)

```fish
arghandle --name {{function_name}} --description {{function_description}} {{other_option ...}}
```

The following options can be placed before option definitions (outside of square
matching brackets or before the first colon):

- `-h`|`--help`: Print [h]elp, to work must be the first option outside of
  square brackets.
- `-n`|`--name`: Specify a [n]ame of a command for error messages (required).
- `-d`|`--description`: Specify a [d]escription of a command for `-h`|`--help`
  (required).
- `-e`|`--exclusive`: Specify [e]xclusive options from option definitions.
- `-m`|`--min-args`: Specify a [m]inimum amount of positional arguments.
- `-M`|`--max-args`: Specify a [M]aximum amount of positional arguments.
- `-c`|`--completion`: Get a [c]ompletion code instead of one for parsing
  arguments, to work must be the first option outside of square brackets.
- `-s`|`--snippet`: Get a [s]nippet code instead of one for parsing arguments,
  must be one of: `code` (Visual Studio Code) and to work must be the first
  option outside of square brackets.
- `-a`|`--markdown`: Get a m[a]rkdown code instead of one for parsing arguments

### Option definitions (`{{option_definition ...}}`)

Each option definition is either:

```fish
{{type|range|enum}} {{short_variant}}/{{long_variant}} {{option_description}}
```

or:

```fish
[ --description {{option_description}} --short {{short_variant}} --long {{long_variant}} {{other_option ...}} ]
```

The first form can be used just when colon (`:`) after
[`{{option ...}}`](#options-option) is placed.

The following options can be placed inside option definitions (inside of square
matching brackets or after the first colon):

- `-d`|`--description`: Specify an option [d]escription (required).
- `-s`|`--short`: Specify a [s]hort variant of an option (required).
- `-l`|`--long`: Specify a [l]ong variant of an option (required).
- `-f`|`--flag`: Specify whether an option is [f]lag and doesn't accept any
- argument.
- `-r`|`--required`: Specify whether an option is [r]equired.
- `-t`|`--type`: Specify a value [t]ype of an option, must be one of: `str`,
- `int`, `float`, `bool`.
- `-R`|`--range`: Specify a valid value [R]ange of an option as a number range.
- `-e`|`--enum`: Specify a valid value of an option as an [e]num.
- `-v`|`--validator`: Specify a value [v]alidator of an option as a call to a
- function (*not supported yet*).
- `-d`|`--default`: Specify a [d]efault value of an option.
- `-a`|`--no-default-assignment`: Specify whether a default value of an option
  should not be [a]ssigned when it's not passed

Dependencies:

- `-t`|`--type` can't be used along with one of the following options as
  these options allow infer option type and therefor `-t`|`--type` becomes
  redundant:
  - `-R`|`--range`
  - `-e`|`--enum`
  - `-d`|`--default`
- `-R`|`--range` and `-e`|`--enum` can't be used together.

Notes:

- Integers are not considered as a special case of floats, they are separate
  types. Don't treat integers as a "subclass" of floats.
- Ranges can consist of `int`egers or `float`s. They can be opened from just one
  side like `1..` or `..10` and closed from both `1..10`.
- Enums can consist of any comma-separated values of the same type.
- `-t`|`--type` is used to just tell valid value type for an option, while
  `-R`|`--range` and `-e`|`--enum` do more: they restrict value to a certain
  subset too.

## Configuration

Configuration is currently done via environment variables whose names start with
`arghandle_`:

- `arghandle_suppress_errors`: Whether to suppress errors (redirect STDERR to
  `/dev/null`).  
  Values:
  - no value: don't suppress errors
  - any non empty value: suppress errors
  
  Affected functions:
  - `arg_parse`
  - `arg_completion`
  - `arg_snippet`
  - `arg_markdown`

- `arghandle_title_color`: Title color for `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_option_color`: Option color for `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_int_placeholder_color`: `int` placeholder color for
  `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_float_placeholder_color`: `float` placeholder color for
  `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_bool_placeholder_color`: `bool` placeholder color for
  `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_str_placeholder_color`: `str` placeholder color for
  `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`

- `arghandle_option_mnemonic_color`: Option mnemonic color for `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_option_default_color`: Option `-d`|`--default` color for
  `-h`|`--help`.  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`
  
- `arghandle_option_deprecation_notice_color`: Option deprecation notice color
  for `-h`|`--help` (*not supported yet*).  
  Values:
  - any color valid for `set_color`.

  Affected functions:
  - `arghandle`
  - `arg_parse`

- `arghandle_option_default_suffix`: Text used to denote an option
  `-d`|`--default` value in a generated completion.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_completion`

- `arghandle_option_min_suffix`: Text used to denote an option minimum
  `-R`|`--range` value in a generated completion.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_completion`
  
- `arghandle_option_max_suffix`: Text used to denote an option maximum
  `-R`|`--range` value in a generated completion.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_completion`

- `arghandle_title_markdown_default_prefix`: A title prefix in generated
  Markdown.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_title_markdown_default_suffix`: A title suffix in generated
  Markdown.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_main_title_markdown_default_format`: A first title format in
  generated Markdown.  
  Values:
  - any value
  
  Parameters:
  - `%s`: function `-n`|`--name`
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_options_title_markdown_default_format`: A second title format in
  generated Markdown.  
  Values:
  - any value
  
  Parameters:
  - `%s`: function `-n`|`--name`
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_option_markdown_default_prefix`: Text used to denote an option
  `-d`|`--default` value in a generated Markdown.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_option_markdown_range_prefix`: Text used to denote an option
  minimum `-R`|`--range` value in a generated Markdown.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_option_markdown_enum_prefix`: Text used to denote an option
  maximum `-R`|`--range` value in a generated Markdown.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`
  
- `arghandle_option_markdown_infinity_sign`: Text used to denote an infinity
  value for opened `-R`|`--range` value in a generated Markdown.  
  Values:
  - any value
  
  Affected functions:
  - `arghandle`
  - `arg_markdown`

- `arghandle_option_usage_max_count`: A maximum amount of arguments which
  can be shown in a usage in `-h`|`--help`. When there are more options
  available all of them are presented as `{{option ...}}`.  
  Values:
  - positive `int`

  Affected functions:
  - `arghandle`
  - `arg_parse`

- `arghandle_range_values_max_count`: A maximum amount of `-R`|`--range` items
  which can be shown in a placeholder. When there are more items available all
  of them are presented as an option `-d`|`--description` value.  
  Values:
  - positive `int`

  Affected functions:
  - `arghandle`
  - `arg_snippet`

## Additional functions

To quicker discover current `arghandle` settings you can use these functions:

- `arghandle_colors`: Print colors used by `arghandle` function
- `arghandle_suffixes`: Print suffixes used by `arghandle` function
- `arghandle_settings`: Print colors and suffixes used by `arghandle` function

## Snippets

These Visual Studio Code snippets can help you to write option definitions
faster:

```json
{
    "arghandle simple": {
        "prefix": ["arghandle", "a"],
        "description": "Simplified 'arghandle' syntax",
        "body": [
            "arghandle ${1|--name,-n|} '${2:Specify a [n]ame of a command for error messages (str)}' ${3|--description,-d|} '${4:Specify a [d]escription of a command for -h/--help (str)}' : \\",
            "\t${5|int,float,bool,str|} ${6:-short-variant}/${7:--long-variant} '${8:option description}'"
        ]
    },
    "arghandle comprehensive": {
        "prefix": ["arghandle-comprehensive", "ac"],
        "description": "Comprehensive 'arghandle' syntax",
        "body": [
            "arghandle ${1|--name,-n|} '${2:Specify a [n]ame of a command for error messages (str)}' ${3|--description,-d|} '${4:Specify a [d]escription of a command for -h/--help (str)}' \\",
            "\t[ ${5|--description,-d|} '${6:option description (str)}' ${7|--long,-l|} ${8:--long-variant} ${9|--short,-s|} ${10:--short-variant} ${11|--type,-t|} ${12|int,float,bool,str|} ]"
        ]
    },
    "arghandle simple definition": {
        "prefix": ["arghandle-definition", "ad"],
        "description": "Simplified 'arghandle' definition",
        "body": "${1|int,float,bool,str|} ${2:-short-variant}/${3:--long-variant} '${4:option description}'"
    },
    "arghandle comprehensive definition": {
        "prefix": ["arghandle-comprehensive-definition", "acd"],
        "description": "Comprehensive 'arghandle' definition",
        "body": "[ ${1|--description,-d|} '${2:option description (str)}' ${3|--long,-l|} ${4:--long-variant} ${5|--short,-s|} ${6:--short-variant} ${7|--type,-t|} ${8|int,float,bool,str|} ]"
    },
    "arghandle simple range definition": {
        "prefix": ["arghandle-range-definition", "ard"],
        "description": "Simplified 'arghandle' range definition",
        "body": "${1:from (int|float)}..${2:to (int|float)} ${3:-short-variant}/${4:--long-variant} '${5:option description (str)}'"
    },
    "arghandle comprehensive range definition": {
        "prefix": ["arghandle-comprehensive-range-definition", "acrd"],
        "description": "Comprehensive 'arghandle' range definition",
        "body": "[ ${1|--description,-d|} '${2:option description (str)}' ${3|--long,-l|} ${4:--long-variant} ${5|--short,-s|} ${6:--short-variant} ${7|--range,-R|} ${8:from (int|float)}..${9:to (int|float)} ]"
    }
}
```
