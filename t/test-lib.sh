# must be sourced

SRCDIR=$(dirname "$TDIR")
export SRCDIR

die()
{
    echo "$@" >&2
    exit 1
}

must_fail()
{
    if "$@"
    then die "Must have failed" >&2
    else echo "Expected failure ignored"
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
            else die "Fail to create temporary directory"
            fi
        else die "Unsupported mktemp invocation: $@"
        fi
    }
fi
