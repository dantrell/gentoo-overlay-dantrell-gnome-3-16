# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2

DESCRIPTION="GNOME framework for accessing online accounts"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeOnlineAccounts"

LICENSE="LGPL-2+"
SLOT="0/1"
KEYWORDS="*"

IUSE="debug gnome +introspection kerberos" # telepathy"

# pango used in goaeditablelabel
# libsoup used in goaoauthprovider
# goa kerberos provider is incompatible with app-crypt/heimdal, see
# https://bugzilla.gnome.org/show_bug.cgi?id=692250
# json-glib-0.16 needed for bug #485092
RDEPEND="
	>=dev-libs/glib-2.35:2
	>=app-crypt/libsecret-0.5
	>=dev-libs/json-glib-0.16
	dev-libs/libxml2:2
	>=net-libs/libsoup-2.42:2.4
	net-libs/rest:0.7
	net-libs/telepathy-glib
	>=net-libs/webkit-gtk-2.7.2:4
	>=x11-libs/gtk+-3.11.1:3
	x11-libs/pango

	introspection? ( >=dev-libs/gobject-introspection-0.6.2:= )
	kerberos? (
		app-crypt/gcr:0=
		app-crypt/mit-krb5 )
"
#	telepathy? ( net-libs/telepathy-glib )
# goa-daemon can launch gnome-control-center
PDEPEND="gnome? ( >=gnome-base/gnome-control-center-3.2[gnome-online-accounts(+)] )"

DEPEND="${RDEPEND}
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.3
	>=dev-util/gdbus-codegen-2.30.0
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig

	dev-libs/gobject-introspection-common
	gnome-base/gnome-common
"
# eautoreconf needs gobject-introspection-common, gnome-common

PATCHES=(
	# From GNOME:
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=01882bde514aae12796c98e03818f8d30cbd13b9
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=53ce478c99d43f0cf8333e452edd228418112a2d
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=674330b0ccb816530ee6d31cea0f752e334f15d7
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=924689ce724cc0f1b893e1e0845c04f59eabd765
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=f5325f00c0d2cae9e5f6253c59c713c4b223af1f
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=389ce7fad248998178778ca4a95dd8d09d4f38eb
	# 	https://git.gnome.org/browse/gnome-online-accounts/commit/?id=236987b0dc06fb429e319bd29a2e9227b78b35e1
	"${FILESDIR}"/${PN}-3.20.6-goa-identity-manager-get-identity-finish-should-return-a-new-ref.patch
	"${FILESDIR}"/${PN}-3.20.6-identity-fix-the-error-handling-when-signing-out-an-identity.patch
	"${FILESDIR}"/${PN}-3.20.6-identity-fix-ensure-credentials-for-accounts-leak.patch
	"${FILESDIR}"/${PN}-3.20.6-identity-dont-leak-the-invocation-when-handling-exchangesecretkeys.patch
	"${FILESDIR}"/${PN}-3.20.6-daemon-dont-leak-the-provider-when-coalescing-ensurecredential-calls.patch
	"${FILESDIR}"/${PN}-3.20.6-identity-dont-leak-operation-result-when-handling-exchangesecretkeys.patch
	"${FILESDIR}"/${PN}-3.20.6-identity-dont-leak-the-invocation-when-handling-signout.patch
)

src_prepare() {
	# From GNOME:
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=750897
	eapply "${FILESDIR}"/${PN}-3.16.3-parallel-make.patch

	eautoreconf
	gnome2_src_prepare
}

# Due to sub-configure
QA_CONFIGURE_OPTIONS=".*"

src_configure() {
	# TODO: Give users a way to set the G/FB/Windows Live secrets
	# telepathy optional support is really badly done, bug #494456
	gnome2_src_configure \
		--disable-static \
		--enable-documentation \
		--enable-exchange \
		--enable-facebook \
		--enable-flickr \
		--enable-foursquare \
		--enable-imap-smtp \
		--enable-media-server \
		--enable-owncloud \
		--enable-pocket \
		--enable-telepathy \
		--enable-windows-live \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable kerberos)
		#$(use_enable telepathy)
	# gudev & cheese from sub-configure is overriden
	# by top level configure, and disabled so leave it like that
}