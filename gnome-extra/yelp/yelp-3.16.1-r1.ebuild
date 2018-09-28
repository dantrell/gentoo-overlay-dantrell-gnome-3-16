# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2

DESCRIPTION="Help browser for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Yelp"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	app-arch/bzip2:=
	>=app-arch/xz-utils-4.9:=
	dev-db/sqlite:3=
	>=dev-libs/glib-2.38:2
	>=dev-libs/libxml2-2.6.5:2
	>=dev-libs/libxslt-1.1.4
	>=gnome-extra/yelp-xsl-3.12
	>=net-libs/webkit-gtk-2.7.1:4
	>=x11-libs/gtk+-3.13.3:3
	x11-themes/adwaita-icon-theme
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.41.0
	dev-util/itstool
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/963662f52cb5be86068f2e71275a4289f9928eca
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/3f6aa816e666dfeb7e409460553da292ef9cffb3
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/9bae912e121e600c423ec64ea9e39622e2243599
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/ccd94656fb1027ed28d601c4244ea968636e4a3a
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/f3fc43ec5681902ee14210714f344553d1221926
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/e36d442420eb746b85d75b2ed2691a0daf737699
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/daa674c2559b564145a8d039286b89f49e31b6b1
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/6f2d5aa706204d3d443e015d3e0ae7b93f59513a
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/3598be880e631b1cd43164f3dd2e48bb8fa53976
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/04683e89cef14f56e4c3d1595424e109f12f5d06
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/7a2f5fc0ab4709d82de7748080dfe920407b763d
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/901b4fb82e007e9d93deb3f1e13cc36d5b2bf37b
	# 	https://gitlab.gnome.org/GNOME/yelp/commit/97a8968c4c37ec3da7605e39a9d4a1157be6281d
	eapply "${FILESDIR}"/${PN}-3.17.3-autotools-adapt-autotools-for-using-webkit2.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-change-headers-files-to-use-webkit2.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-replace-navigation-policy-decision-requested-signal-by-decide-policy-signal.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-replace-script-alert-signal-by-script-dialog-signal.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-rename-wkwebsettings-to-wksettings-and-adapt-properties.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-implement-view-print-action-using-webkit2-api.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-use-wkfindcontroller-instead-of-deprecated-search-functions-in-wkwebview.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-replace-populate-popup-signal-by-context-menu-signal.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-implement-web-extension-to-deal-with-dom-tree.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-implement-pages-load-in-webkit2.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-test-port-yelp-tests-to-webkit2.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-view-implement-web-extension-to-load-resources.patch
	eapply "${FILESDIR}"/${PN}-3.17.3-yelp-window-remove-scrolledwindow-to-hold-webview.patch

	# Fix compatibility with Gentoo's sys-apps/man
	# https://bugzilla.gnome.org/show_bug.cgi?id=648854
	eapply "${FILESDIR}"/${PN}-3.16.0-man-compatibility.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--enable-bz2 \
		--enable-lzma
}
