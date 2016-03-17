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

if ! command -v seq >/dev/null >/dev/null
then
    seq()
    {
        local i

        if test "$#" -ne 2
        then die "Unexpected seq call: $@"
        fi

        i="$1"
        while test "$i" -le "$2"
        do
            printf "%d\n" "$i"
            i=$(expr "$i" + 1)
        done
    }
fi
