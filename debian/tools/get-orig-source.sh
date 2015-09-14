#! /bin/sh
set -e

PKGVER=$(dpkg-parsechangelog | sed -n '/^Version:/s/^Version: //p')

get_snapshot_version () {
        ORIGDIR="$(pwd)"
        COMMITID="$(echo ${PKGVER} | cut -d- -f2 | tr -d 'g')"
        TEMPDIR=$(mktemp -d)
        TARVERSION="$(echo $PKGVER | sed -e "s,-[^-]*$,,")"

        echo >&2 "* Building in '${TEMPDIR}/syslog-ng'..."

        git clone --recursive https://github.com/balabit/syslog-ng "${TEMPDIR}/syslog-ng"
        cd "${TEMPDIR}/syslog-ng"
        ./autogen.sh
        ./configure --with-libmongo-client=internal \
                    --with-ivykis=internal \
                    --with-jasonc=internal \
                    --with-librabbitmq-client=internal
        make dist
        mv syslog-ng-*.tar.gz ${ORIGDIR}/../syslog-ng_${TARVERSION}.orig.tar.gz
        cd "${ORIGDIR}"
        rm -rf "${TEMPDIR}"
}

case "${PKGVER}" in
        *-g[0-9a-f]*)
                cat >&2 <<EOF
WARNING: Constructing a make dist tarball from a git checkout!
WARNING: Some build-dependencies may need to be installed, along with git!
EOF
                get_snapshot_version "${PKGVER}"
                ;;
        *)
                uscan --force-download --verbose
                ;;
esac
