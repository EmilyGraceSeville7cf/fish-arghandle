# Argument handler

Parses arguments, provides automatically generated help available via `-h`|`--help` and generates completions. Under the hood it generates a code to do all this stuff, that is why to make it work argument handler (`arghandle` function) should be wrapped in `eval`:

```fish
eval (arghandle ...)
```

where instead (`...`) of ellipsis valid command options are written and other things.

## Introduction

Fish shell provides facilities to parse arguments and write completions, but they are separated. In other words, parsing is done completely independent from completions. That means that programmers have to adjust completions manually to match argument parsing done via `argparse` and vice versa. It makes this whole process error-prone and unreliable.

This argument handler aims to solve this issue. It allows users to define valid command options, do argument parsing and get help system with completions out of the box. Programmers don't have to define `-h`|`--help` option themselves, it's always provided by default to keep consistency between ways to invoke help for different user functions.

Let's say, Fish programmer wants to define a function which searches for some book in some online store (we don't care about implementation details for now). There are several book filtering criteria like it's author, name, etc. Let's focus on these first too. To provide them to the function programmer can use options like `-a`|`--author` and `-b`|`--book`:

```fish
# Variable is used just not to redescribe all options again when completions should be generated.
set __search_for_book_option_specification --name 'search_for_book' --description 'Search for a book in an online store' \
    [ --description 'A book author' --short a --long author --type str ] \
    [ --description 'A book name' --short b --long book --type str ]

function search_for_book  
    # The most important line, without it nothing works.
    # Generated code by arghandle contains call to argparse and a check for -h|--help option existence in $argv.
    # That's why there is no explicit mention for $argv in arghandle call.
    eval (arghandle $__search_for_book_option_specification)

    # Some stuff to download book we don't care about now.
end

# Completions are generated somewhere here, but we don't mind about it for now.
```

`$__search_for_book_option_specification` variable contains option descriptions and their properties. Note that each option definition is enclosed inside brackets (which should be separate arguments as shown above). It could be rewritten in a JSON alike this:

```json
{
    "name": "search_for_book",
    "description": "Search for a book in an online store",
    "definitions": [
        {
            "description": "A book",
            "short": "b",
            "long": "book",
            "type": "str"
        },
        {
            "description": "An author",
            "short": "a",
            "long": "author",
            "type": "str"
        }
    ]
}
```

This JSON is not currently parsed by argument parser (`arghandle` function), it is just a product of our imagination which illustrates meaning of all option definitions.

Because option values often have some constraints simplified syntax has been developed to explain such restrictions quicker. So the example above can be rewritten as:

```fish
# Types should be specified for all options, to guarantee all data
# passed in a book search function has the right type. Also note ':'
# after '--description' option, it signifies that this simplified syntax
# is expected to be used. Without it code will not work.
set __search_for_book_option_specification --name 'search_for_book' --description 'Search for a book in an online store' : \
    str a/author 'A book author' \
    str b/book 'A book name'

function search_for_book  
    eval (arghandle $__search_for_book_option_specification)

    # Some stuff to download book we don't care about now.
end
```

While using this syntax it's recommended to write each option definition on a separate line.

## Syntax

```fish
__arghandle_usage 'arghandle [OPTIONS] [OPTION_DEFINITION]...'
```

### Options

The following options can be placed before option definitions (outside of square matching brackets):

- `-h`|`--help`: Print [h]elp, to work must be the first option outside of square brackets.
- `-n`|`--name`: Specify a [n]ame of a command for error messages (required).
- `-d`|`--description`: Specify a [d]escription of a command for -h/--help (required).
- `-e`|`--exclusive`: Specify [e]xclusive options from option definitions.
- `-m`|`--min-args`: Specify a [m]inimum amount of positional arguments.
- `-M`|`--max-args`: Specify a [M]aximum amount of positional arguments.

### Option definitions

The following options can be placed inside option definitions (inside of square matching brackets):

- `-d`|`--description`: Specify an option [d]escription.
- `-s`|`--short`: Specify a [s]hort variant of an option.
- `-l`|`--long`: Specify a [l]ong variant of an option.
- `-r`|`--required`: Specify whether an option is [r]equired.
- `-t`|`--type`: Specify a value [t]ype of an option, must be one of: str, int, float, bool.
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

## Useful functions

To quicker discover current `arghandle` settings you can use these functions:

- `arghandle_colors`: Print colors used by `arghandle` function
- `arghandle_suffixes`: Print suffixes used by `arghandle` function
- `arghandle_settings`: Print colors and suffixes used by `arghandle` function
