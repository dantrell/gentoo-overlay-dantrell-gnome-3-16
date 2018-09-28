# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME_ORG_MODULE="vte"

inherit autotools gnome2

DESCRIPTION="GNOME Setuid helper for opening ptys"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/Terminal/VTE"
# gnome-pty-helper is inside vte
SRC_URI="https://gitlab.gnome.org/GNOME/${GNOME_ORG_MODULE}/-/archive/${PV}/${GNOME_ORG_MODULE}-${PV}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="+hardened"

RESTRICT="mirror"

# gnome-pty-helper was spit out with 0.27.90
RDEPEND="
	!<x11-libs/vte-0.27.90
"
DEPEND="${RDEPEND}
	dev-util/gtk-doc
"

S="${WORKDIR}/${GNOME_ORG_MODULE}-${PV}/${PN}"

src_prepare() {
	# As recommended by upstream (/usr/libexec/$PN is a setgid binary)
	if use hardened; then
		export SUID_CFLAGS="-fPIE ${SUID_CFLAGS}"
		export SUID_LDFLAGS="-pie ${SUID_LDFLAGS}"
	fi

	eautoreconf
	gnome2_src_prepare
}
