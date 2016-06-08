# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes" # Needed with USE 'sendto'

inherit eutils gnome2 readme.gentoo versionator virtualx

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-2+ LGPL-2+ FDL-1.1"
SLOT="0"
KEYWORDS="*"

# profiling?
IUSE="exif gnome +introspection packagekit +previewer sendto tracker vanilla xmp"

# FIXME: tests fails under Xvfb, but pass when building manually
# "FAIL: check failed in nautilus-file.c, line 8307"
RESTRICT="test"

# FIXME: selinux support is automagic
# Require {glib,gdbus-codegen}-2.30.0 due to GDBus API changes between 2.29.92
# and 2.30.0
COMMON_DEPEND="
	>=dev-libs/glib-2.43.4:2[dbus]
	>=x11-libs/pango-1.28.3
	>=x11-libs/gtk+-3.15.2:3[introspection?]
	>=dev-libs/libxml2-2.7.8:2
	>=gnome-base/gnome-desktop-3:3=

	gnome-base/dconf
	>=gnome-base/gsettings-desktop-schemas-3.8.0
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender

	exif? ( >=media-libs/libexif-0.6.20 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.4:= )
	tracker? ( >=app-misc/tracker-0.16:= )
	xmp? ( >=media-libs/exempi-2.1.0 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-lang/perl-5
	>=dev-util/gdbus-codegen-2.33
	>=dev-util/gtk-doc-am-1.4
	>=dev-util/intltool-0.40.1
	sys-devel/gettext
	virtual/pkgconfig
	x11-proto/xproto
"
RDEPEND="${COMMON_DEPEND}
	packagekit? ( app-admin/packagekit-base )
	sendto? ( !<gnome-extra/nautilus-sendto-3.0.1 )
"

# For eautoreconf
#	gnome-base/gnome-common
#	dev-util/gtk-doc-am"

PDEPEND="
	gnome? (
		>=x11-themes/gnome-icon-theme-1.1.91
		x11-themes/gnome-icon-theme-symbolic )
	tracker? ( >=gnome-extra/nautilus-tracker-tags-0.12 )
	previewer? (
		>=gnome-extra/sushi-0.1.9
		>=media-video/totem-$(get_version_component_range 1-2) )
	sendto? ( >=gnome-extra/nautilus-sendto-3.0.1 )
	>=gnome-base/gvfs-1.14[gtk]
"
# Need gvfs[gtk] for recent:/// support

src_prepare() {
	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi

	if ! use vanilla; then
		epatch "${FILESDIR}"/${PN}-3.16.2-reorder-context-menu.patch
		epatch "${FILESDIR}"/${PN}-3.16.2-support-slow-double-click-to-rename.patch
		#epatch "${FILESDIR}"/${PN}-3.16.2-use-old-icon-grid-and-text-width-proportions.patch

		# From GNOME
		# 	https://git.gnome.org/browse/nautilus/commit/?id=986eafd989bdaf8ad003a61e2ed0fa8d21dab87b
		# 	https://git.gnome.org/browse/nautilus/commit/?id=2e1ac987268cd57349cdc2763d2442b532ce3c49
		# 	https://git.gnome.org/browse/nautilus/commit/?id=3409a397d8cd46821ceb2bdca70b88d1aaf5c1f7
		# 	https://git.gnome.org/browse/nautilus/commit/?id=2f206f0009be7f3a1c4d5968bb12e4d128dd9ad1
		# 	https://git.gnome.org/browse/nautilus/commit/?id=efb04b8b9d9d7d1121caff4f419acaf98967e704
		# 	https://git.gnome.org/browse/nautilus/commit/?id=a6821c163f2982acd330c2226268f6dfb9972fc1
		epatch "${FILESDIR}"/${PN}-3.17.2-view-make-the-zoom-slider-the-preference-itself.patch
		#epatch "${FILESDIR}"/${PN}-3.17.3-preferences-make-toolbar-hidden-files-permanent-setting.patch
		epatch "${FILESDIR}"/${PN}-3.17.3-preferences-make-the-view-buttons-permanent-setting.patch
		epatch "${FILESDIR}"/${PN}-3.19.90-general-add-another-zoom-level.patch
		epatch "${FILESDIR}"/${PN}-3.19.90-canvas-item-dont-multiply-padding-for-label.patch
		epatch "${FILESDIR}"/${PN}-3.19.90-canvas-item-add-dynamic-label-sizing-for-zoom-levels.patch
	fi

	# From GNOME
	# 	https://git.gnome.org/browse/nautilus/commit/?id=bfe878e4313e21b4c539d95a88d243065d30fc2c
	# 	https://git.gnome.org/browse/nautilus/commit/?id=079d349206c2dd182df82e4b26e3e23c9b7a75c4
	# 	https://git.gnome.org/browse/nautilus/commit/?id=e96f73cf1589c023ade74e4aeb16a0c422790161
	epatch "${FILESDIR}"/${PN}-3.17.3-ignore-no-desktop-if-not-first-launch.patch
	epatch "${FILESDIR}"/${PN}-3.18.5-thumbnails-avoid-crash-with-jp2-images.patch
	epatch "${FILESDIR}"/${PN}-3.20.2-do-not-reset-double-click-status-on-pointer-movement.patch

	# Remove -D*DEPRECATED flags. Don't leave this for eclass! (bug #448822)
	sed -e 's/DISABLE_DEPRECATED_CFLAGS=.*/DISABLE_DEPRECATED_CFLAGS=/' \
		-i configure || die "sed failed"

	gnome2_src_prepare
}

src_configure() {
	DOCS="AUTHORS HACKING MAINTAINERS NEWS README* THANKS"
	gnome2_src_configure \
		--disable-profiling \
		--disable-update-mimedb \
		$(use_enable exif libexif) \
		$(use_enable introspection) \
		$(use_enable packagekit) \
		$(use_enable sendto nst-extension) \
		$(use_enable tracker) \
		$(use_enable xmp)
}

src_test() {
	gnome2_environment_reset
	unset DBUS_SESSION_BUS_ADDRESS
	export GSETTINGS_BACKEND="memory"
	Xemake check
	unset GSETTINGS_BACKEND
}

src_install() {
	use previewer && readme.gentoo_create_doc
	gnome2_src_install
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}
