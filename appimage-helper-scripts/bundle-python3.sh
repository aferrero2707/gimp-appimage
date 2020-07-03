#! /bin/bash

# Bundle the python runtime
PYTHON_PREFIX=$(pkg-config --variable=prefix python3)
PYTHON_LIBDIR=$(pkg-config --variable=libdir python3)
PYTHON_VERSION=$(pkg-config --modversion python3)
echo "PYTHON_PREFIX=${PYTHON_PREFIX}"
echo "PYTHON_LIBDIR=${PYTHON_LIBDIR}"
echo "PYTHON_VERSION=${PYTHON_VERSION}"
if [ x"${PYTHON_PREFIX}" = "x" ]; then
	echo "Could not determine PYTHON installation prefix, exiting."
	exit 1
fi
if [ x"${PYTHON_LIBDIR}" = "x" ]; then
	echo "Could not determine PYTHON library path, exiting."
	exit 1
fi
if [ x"${PYTHON_VERSION}" = "x" ]; then
	echo "Could not determine PYTHON version, exiting."
	exit 1
fi

cp -a "${PYTHON_PREFIX}/bin"/python* "$APPDIR/usr/bin" || exit 1
rm -rf "$APPDIR/usr/lib/python${PYTHON_VERSION}"
mkdir -p "$APPDIR/usr/lib"
cp -a "${PYTHON_LIBDIR}/python${PYTHON_VERSION}" "$APPDIR/usr/lib" || exit 1

mkdir -p "$APPDIR/usr/lib/python${PYTHON_VERSION}/site-packages"
cp -a /usr/local/lib64/python${PYTHON_VERSION}/site-packages/* "$APPDIR/usr/lib/python${PYTHON_VERSION}/site-packages"

PYGLIB_LIBDIR=$(pkg-config --variable=libdir pygobject-2.0)
if [ x"${PYGLIB_LIBDIR}" = "x" ]; then
	echo "Could not determine PYGOBJECT library path, exiting."
	exit 1
fi
cp -a "${PYGLIB_LIBDIR}"/libpyglib*.so* "$APPDIR/usr/lib"
(cd "$APPDIR/usr" && mkdir -p lib64 && cd lib64 && rm -rf python${PYTHON_VERSION} && ln -s ../lib/python${PYTHON_VERSION} .) || exit 1
ls -l "$APPDIR/usr/lib64"



gssapilib=$(ldconfig -p | grep 'libgssapi_krb5.so.2 (libc6,x86-64)'| awk 'NR==1{print $NF}')
if [ x"$gssapilib" != "x" ]; then
	gssapilibdir=$(dirname "$gssapilib")
	cp -a "$gssapilibdir"/libgssapi_krb5*.so* "$APPDIR/usr/lib"
fi

