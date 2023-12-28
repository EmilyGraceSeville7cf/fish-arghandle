# Argument handler

Parses arguments, provides automatically generated help available via `-h`|`--help`, generates completions and snippets. Under the hood it generates a code to do all this stuff, that is why to make it work argument handler (`arghandle` function) should be wrapped in `eval`:

```fish
eval (arghandle {{option ...}})
```

## Pros and cons

- :white_check_mark: One option specification for all kind of things like help, completions and snippets.
- :white_check_mark: Better type-safety, no need to check whether some argument in a specific range/enum or of some type manually.
- :negative_squared_cross_mark: Syntax may be more complicated than for `argparse` and `complete`, but we are working on improving it.

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

The latter syntax allows provide more details about each available option, like its default value.

While `arghandle` parses incoming arguments for `search_book` and prints automatically generated help:

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

when requested with `--help`|`-h` option it also provides completion (requested with `--completion`|`-c` option):

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

The following options can be placed before option definitions (outside of square matching brackets or before the first colon):

- `-h`|`--help`: Print [h]elp, to work must be the first option outside of square brackets.
- `-n`|`--name`: Specify a [n]ame of a command for error messages (required).
- `-d`|`--description`: Specify a [d]escription of a command for `-h`|`--help` (required).
- `-e`|`--exclusive`: Specify [e]xclusive options from option definitions.
- `-m`|`--min-args`: Specify a [m]inimum amount of positional arguments.
- `-M`|`--max-args`: Specify a [M]aximum amount of positional arguments.
- `-c`|`--completion`: Get a [c]ompletion code instead of one for parsing arguments, to work must be the first option outside of square brackets.
- `-s`|`--snippet` Get a [s]nippet code instead of one for parsing arguments, must be one of: `code` (Visual Studio Code) and to work must be the first option outside of square brackets.

### Option definitions (`{{option_definition ...}}`)

Each option definition is either:

```fish
{{type|range|enum}} {{short_variant}}/{{long_variant}} {{option_description}}
```

or:

```fish
[ --description {{option_description}} --short {{short_variant}} --long {{long_variant}} {{other_option ...}} ]
```

The first form can be used just when colon (`:`) after [`{{option ...}}`](#options-option) is placed.

The following options can be placed inside option definitions (inside of square matching brackets or after the first colon):

- `-d`|`--description`: Specify an option [d]escription (required).
- `-s`|`--short`: Specify a [s]hort variant of an option (required).
- `-l`|`--long`: Specify a [l]ong variant of an option (required).
- `-f`|`--flag`: Specify whether an option is [f]lag and doesn't accept any argument.
- `-r`|`--required`: Specify whether an option is [r]equired.
- `-t`|`--type`: Specify a value [t]ype of an option, must be one of: `str`, `int`, `float`, `bool`.
- `-R`|`--range`: Specify a valid value [R]ange of an option as a number range.
- `-e`|`--enum`: Specify a valid value of an option as an [e]num.
- `-v`|`--validator`: Specify a value [v]alidator of an option as a call to a function.
- `-d`|`--default`: Specify a [d]efault value of an option.

Notes:

- Ranges can consist of `int`egers or `float`s. They can be opened from just one side like `1..` or `..10` and closed from both `1..10`.
- Enums can consist of any comma-separated values. If all values have one type, then it's the type of the enum. Otherwise, enum considered to contain `str`ings.
- `-R`|`--range` and `-e`|`--enum` are mutually exclusive.
- `-t`|`--type` is used to just tell valid value type for an option, while `-R`|`--range` and `-e`|`--enum` do more: they restrict value to a certain subset too. By default `-t`|`--type` assumed to be `str` unless explicitly specified or one of the following options are used:
  - `-R`|`--range` - tells that `-t`|`--type` is implicitly `int` or `float`
  - `-e`|`--enum` - tells `-t`|`--type` implicitly  

## Additional functions

To quicker discover current `arghandle` settings you can use these functions:

- `arghandle_colors`: Print colors used by `arghandle` function
- `arghandle_suffixes`: Print suffixes used by `arghandle` function
- `arghandle_settings`: Print colors and suffixes used by `arghandle` function
