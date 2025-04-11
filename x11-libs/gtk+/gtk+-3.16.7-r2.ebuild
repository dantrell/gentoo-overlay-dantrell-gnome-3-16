# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools flag-o-matic gnome2 multilib virtualx multilib-minimal

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="3/16" # From WebKit: http://trac.webkit.org/changeset/195811
KEYWORDS="*"

IUSE="aqua broadway cloudprint colord cups examples +introspection test +vanilla-touchpad vim-syntax wayland X xinerama"
REQUIRED_USE="
	|| ( aqua wayland X )
	xinerama? ( X )
"

# Upstream wants us to do their job:
# https://bugzilla.gnome.org/show_bug.cgi?id=768662#c1
RESTRICT="test"

# FIXME: introspection data is built against system installation of gtk+:3,
# bug #????
COMMON_DEPEND="
	>=dev-libs/atk-2.15[introspection?,${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.43.4:2[${MULTILIB_USEDEP}]
	media-libs/fontconfig[${MULTILIB_USEDEP}]
	>=media-libs/libepoxy-1.0[X(+)?,${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.14[aqua?,glib,svg(+),X?,${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.30:2[introspection?,${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.36.7[introspection?,${MULTILIB_USEDEP}]
	x11-misc/shared-mime-info

	cloudprint? (
		>=net-libs/rest-0.7[${MULTILIB_USEDEP}]
		>=dev-libs/json-glib-1.0[${MULTILIB_USEDEP}] )
	colord? ( >=x11-misc/colord-0.1.9:0=[${MULTILIB_USEDEP}] )
	cups? ( >=net-print/cups-1.2[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-1.39:= )
	wayland? (
		>=dev-libs/wayland-1.5.91[${MULTILIB_USEDEP}]
		media-libs/mesa[wayland,${MULTILIB_USEDEP}]
		>=x11-libs/libxkbcommon-0.2[${MULTILIB_USEDEP}]
	)
	X? (
		>=app-accessibility/at-spi2-atk-2.5.3[${MULTILIB_USEDEP}]
		media-libs/mesa[X(+),${MULTILIB_USEDEP}]
		x11-libs/libX11[${MULTILIB_USEDEP}]
		>=x11-libs/libXi-1.3[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		>=x11-libs/libXrandr-1.3[${MULTILIB_USEDEP}]
		x11-libs/libXcursor[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
		x11-libs/libXcomposite[${MULTILIB_USEDEP}]
		x11-libs/libXdamage[${MULTILIB_USEDEP}]
		xinerama? ( x11-libs/libXinerama[${MULTILIB_USEDEP}] )
	)
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.1.2
	dev-libs/libxslt
	dev-libs/gobject-introspection-common
	>=dev-util/gdbus-codegen-2.38.2
	>=dev-build/gtk-doc-am-1.20
	>=sys-devel/gettext-0.18.3[${MULTILIB_USEDEP}]
	virtual/pkgconfig
	X? ( x11-base/xorg-proto )
	test? (
		media-fonts/font-misc-misc
		media-fonts/font-cursor-misc )
	examples? ( media-libs/libcanberra[gtk3] )
"
# gtk+-3.2.2 breaks Alt key handling in <=x11-libs/vte-0.30.1:2.90
# gtk+-3.3.18 breaks scrolling in <=x11-libs/vte-0.31.0:2.90
RDEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-update-icon-cache-3
	!<gnome-base/gail-1000
	!<x11-libs/vte-0.31.0:2.90
"
# librsvg for svg icons (PDEPEND to avoid circular dep), bug #547710
PDEPEND="
	gnome-base/librsvg[${MULTILIB_USEDEP}]
	>=x11-themes/adwaita-icon-theme-3.14
	vim-syntax? ( app-vim/gtk-syntax )
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gtk-query-immodules-3.0$(get_exeext)
)

strip_builddir() {
	local rule=$1
	shift
	local directory=$1
	shift
	sed -e "s/^\(${rule} =.*\)${directory}\(.*\)$/\1\2/" -i $@ \
		|| die "Could not strip director ${directory} from build."
}

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gtk+/commit/631f6b536485829a0bd00532f5826ad302b4951b
	eapply "${FILESDIR}"/${PN}-3.21.3-configure-fix-detecting-cups-2-x.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/862cac7fe63c712d54936548a245707f2a966e78
	#
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/a3b402a9498787d2704f6ab228d3814683c946eb
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/8c2b3930daa6d3886626907fbc79b812579b42d7
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/5092febaf841939c7b3539ef447f43e1ce464037
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/6cd45af8b0afb3758df6bc7679b651033b39c9c4
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/777ac92862529d9b9065a2f9e86f055bbfdd4b61
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/3808322f80e322195165a8162d9c8765a68bcc52
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/8b1c9c0687e4d2deb65a7235e97bd1a2e63447ab
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/97e67e21a1e21215f1191a5be1f2fb102fb2d6a0
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/67ae7322e9569d106328ddab39296ffc9f64961a
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/4457be688da16811d2e558519b566b2605de346d
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/e736e8dcb997da651747804f069b5db8417c43bf
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/d756463d9b2ad1cf84c0ca4313a19227a89796b4
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/e55b3c6501c01c085ca0583e05e1f95b4705a70f
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/dc77989a1c67bce242873de0e7dc0b2f9ded6cb7

	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/defa1e9c0da70b270b63093eb2bc7c11968dab2e
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/f8b24884b5cc6fbd582eae5e7aab3e234b3c4c26
	# 	https://gitlab.gnome.org/GNOME/gtk/-/commit/809c27e5d87821862a1010c5a0d4cb2f9e2fa8b1
	if ! use vanilla-touchpad; then
		eapply "${FILESDIR}"/${PN}-3.17.6-gtkgesture-minor-cleanup.patch

		eapply "${FILESDIR}"/${PN}-3.17.7-gdk-add-touchpad-gesture-events-and-event-types.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gdk-add-gdk-touchpad-gesture-mask-to-gdkeventmask.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gdk-proxy-touchpad-events-through-the-client-side-window-hierarchy.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkmain-handle-rewriting-of-event-fields-during-grabs-for-touchpad-events.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkwidget-ensure-touchpad-events-trigger-the-bubbling-phase.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-eventcontroller-add-private-filter-method.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-refactor-gtk-gesture-handle-event.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-filter-out-touchpad-events-by-default.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-refactor-n-points-querying-into-a-single-function.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-handle-touchpad-events.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-accumulate-touchpad-events-dx-dy-in-point-data.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-add-docs-blurb-about-touchpad-gestures.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-add-touchpad-gesture-event-bit-to-the-controller-evmask.patch
		eapply "${FILESDIR}"/${PN}-3.17.7-gtkgesture-add-note-to-gtk-gesture-get-bounding-box.patch

		eapply "${FILESDIR}"/${PN}-3.18.0-gesture-strengthen-against-destroyed-windows.patch
		eapply "${FILESDIR}"/${PN}-3.18.6-document-gdk-touchpad-gesture-mask.patch
		eapply "${FILESDIR}"/${PN}-3.18.7-gestures-add-some-nullable-annotations.patch
	fi

	if ! use vanilla-touchpad; then
		eapply "${FILESDIR}"/${PN}-3.14.15-gdkenumtypes.patch
	fi


	# -O3 and company cause random crashes in applications. Bug #133469
	replace-flags -O3 -O2
	strip-flags

	if ! use test ; then
		# don't waste time building tests
		strip_builddir SRC_SUBDIRS testsuite Makefile.{am,in}

		# the tests dir needs to be build now because since commit
		# 7ff3c6df80185e165e3bf6aa31bd014d1f8bf224 tests/gtkgears.o needs to be there
		# strip_builddir SRC_SUBDIRS tests Makefile.{am,in}
	fi

	if ! use examples; then
		# don't waste time building demos
		strip_builddir SRC_SUBDIRS demos Makefile.{am,in}
		strip_builddir SRC_SUBDIRS examples Makefile.{am,in}
	fi

	# gtk-update-icon-cache is installed by dev-util/gtk-update-icon-cache
	eapply "${FILESDIR}"/${PN}-3.16.2-remove_update-icon-cache.patch

	# call eapply_user (implicitly) before eautoreconf
	gnome2_src_prepare
	eautoreconf
}

multilib_src_configure() {
	# need libdir here to avoid a double slash in a path that libtool doesn't
	# grok so well during install (// between $EPREFIX and usr ...)
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		$(use_enable aqua quartz-backend) \
		$(use_enable broadway broadway-backend) \
		$(use_enable cloudprint) \
		$(use_enable colord) \
		$(use_enable cups cups auto) \
		$(multilib_native_use_enable introspection) \
		$(use_enable wayland wayland-backend) \
		$(use_enable X x11-backend) \
		$(use_enable X xcomposite) \
		$(use_enable X xdamage) \
		$(use_enable X xfixes) \
		$(use_enable X xkb) \
		$(use_enable X xrandr) \
		$(use_enable xinerama) \
		--disable-papi \
		--disable-mir-backend \
		--enable-man \
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		CUPS_CONFIG="${EPREFIX}/usr/bin/${CHOST}-cups-config"

	# work-around gtk-doc out-of-source brokedness
	if multilib_is_native_abi; then
		local d
		for d in gdk gtk libgail-util; do
			ln -s "${S}"/docs/reference/${d}/html docs/reference/${d}/html || die
		done
	fi
}

multilib_src_test() {
	"${EROOT}${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/gtk" || die
	GSETTINGS_SCHEMA_DIR="${S}/gtk" virtx emake check
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	insinto /etc/gtk-3.0
	doins "${FILESDIR}"/settings.ini
	einstalldocs
}

pkg_preinst() {
	gnome2_pkg_preinst

	multilib_pkg_preinst() {
		# Make immodules.cache belongs to gtk+ alone
		local cache="usr/$(get_libdir)/gtk-3.0/3.0.0/immodules.cache"

		if [[ -e ${EROOT}${cache} ]]; then
			cp "${EROOT}"${cache} "${ED}"/${cache} || die
		else
			touch "${ED}"/${cache} || die
		fi
	}
	multilib_parallel_foreach_abi multilib_pkg_preinst
}

pkg_postinst() {
	gnome2_pkg_postinst

	multilib_pkg_postinst() {
		gnome2_query_immodules_gtk3 \
			|| die "Update immodules cache failed (for ${ABI})"
	}
	multilib_parallel_foreach_abi multilib_pkg_postinst

	if ! has_version "app-text/evince"; then
		elog "Please install app-text/evince for print preview functionality."
		elog "Alternatively, check \"gtk-print-preview-command\" documentation and"
		elog "add it to your settings.ini file."
	fi
}

pkg_postrm() {
	gnome2_pkg_postrm

	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		multilib_pkg_postrm() {
			rm -f "${EROOT}"usr/$(get_libdir)/gtk-3.0/3.0.0/immodules.cache
		}
		multilib_foreach_abi multilib_pkg_postrm
	fi
}
