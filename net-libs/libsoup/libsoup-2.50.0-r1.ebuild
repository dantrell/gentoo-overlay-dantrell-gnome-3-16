# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome2 multilib-minimal python-any-r1

DESCRIPTION="HTTP client/server library for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/libsoup"

LICENSE="LGPL-2+"
SLOT="2.4"
KEYWORDS="*"

IUSE="debug +introspection samba ssl test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4:2[${MULTILIB_USEDEP}]
	>=dev-db/sqlite-3.8.2:3[${MULTILIB_USEDEP}]
	>=net-libs/glib-networking-2.38.2[ssl?,${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
	samba? ( net-fs/samba )
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-build/gtk-doc-am-1.10
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
	test? ( >=dev-libs/glib-2.40:2[${MULTILIB_USEDEP}] )
"
#	test? (	www-servers/apache[ssl,apache2_modules_auth_digest,apache2_modules_alias,apache2_modules_auth_basic,
#		apache2_modules_authn_file,apache2_modules_authz_host,apache2_modules_authz_user,apache2_modules_dir,
#		apache2_modules_mime,apache2_modules_proxy,apache2_modules_proxy_http,apache2_modules_proxy_connect]
#		dev-lang/php[apache2,xmlrpc]
#		net-misc/curl
#		net-libs/glib-networking[ssl])"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/libsoup/-/commit/03c91c76daf70ee227f38304c5e45a155f45073d
	"${FILESDIR}"/${PN}-2.59.90.1-libsoup-fix-chunked-decoding-buffer-overrun-cve-2017-2885.patch
)

src_prepare() {
	if ! use test; then
		# don't waste time building tests (bug #226271)
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi

	# fix sorting when LC_ALL/LC_COLLATE is set, bug #560258
	# fixed upstream in 2.52
	sed -e 's/LANG=C sort/LC_ALL=C sort/' -i libsoup/Makefile.{am,in} || die "sed failed"

	gnome2_src_prepare
}

src_configure() {
	# FIXME: we need addpredict to workaround bug #324779 until
	# root cause (bug #249496) is solved
	addpredict /usr/share/snmp/mibs/.index

	multilib-minimal_src_configure
}

multilib_src_configure() {
	# Disable apache tests until they are usable on Gentoo, bug #326957
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--disable-static \
		--disable-tls-check \
		--without-gnome \
		--without-apache-httpd \
		$(usex debug --enable-debug=yes ' ') \
		$(multilib_native_use_enable introspection) \
		$(use_with samba ntlm-auth '${EPREFIX}'/usr/bin/ntlm_auth)

	if multilib_is_native_abi; then
		# fix gtk-doc
		ln -s "${S}"/docs/reference/html docs/reference/html || die
	fi
}

multilib_src_install() {
	gnome2_src_install
}
