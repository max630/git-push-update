# must be sourced

SRCDIR=$(dirname "$TDIR")
export SRCDIR

must_fail()
{
    if "$@"
    then
        echo "Must have failed" >&2
        exit 1
    else
        echo "Expected failure ignored"
    fi
}

if ! command -v mktemp >/dev/null
then
    mktemp()
    {
        local res
        if test "$#" -eq 1 -a "$1" = "-d"
        then
            res="$TMP/$RANDOM"
            if mkdir "$res"
            then
                echo "$res"
                return
            else
                echo "Fail to create temporary directory" >&2
                exit 1
            fi
        else
            echo "Unsupported mktemp invocation: $@" >&2
            exit 1
        fi
    }
fi
