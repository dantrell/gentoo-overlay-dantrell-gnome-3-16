# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2

DESCRIPTION="Disk Utility for GNOME using udisks"
HOMEPAGE="https://wiki.gnome.org/Apps/Disks"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="fat gnome systemd"

COMMON_DEPEND="
	>=dev-libs/glib-2.31:2[dbus]
	>=sys-fs/udisks-2.1.1:2
	>=x11-libs/gtk+-3.12:3
	>=app-arch/xz-utils-5.0.5
	>=app-crypt/libsecret-0.7
	dev-libs/libpwquality
	systemd? ( >=sys-apps/systemd-44:0= )
"
RDEPEND="${COMMON_DEPEND}
	>=media-libs/libdvdread-4.2.0:0=
	>=media-libs/libcanberra-0.1[gtk3]
	>=x11-libs/libnotify-0.7:=
	x11-themes/adwaita-icon-theme
	fat? ( sys-fs/dosfstools )
	gnome? ( >=gnome-base/gnome-settings-daemon-3.8 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.50
	dev-libs/libxslt
	gnome-base/gnome-common
	virtual/pkgconfig
"

src_prepare() {
	# Fix USE=-gnome, bug #478820
	eapply "${FILESDIR}"/${PN}-3.10.0-kill-gsd-automagic.patch
	eapply "${FILESDIR}"/${PN}-3.10.0-raise-gsd-dependency.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_enable gnome gsd-plugin) \
		$(use_enable systemd libsystemd-login)
}
