# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="Note editor designed to remain simple to use"
HOMEPAGE="https://wiki.gnome.org/Apps/Notes"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.28:2
	>=x11-libs/gtk+-3.11.4:3
	>=gnome-extra/evolution-data-server-3.13.90:=
	net-libs/webkit-gtk:4
	net-libs/gnome-online-accounts:=
	dev-libs/libxml2
	>=app-misc/tracker-1:0=
	sys-apps/util-linux
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	dev-libs/appstream-glib
	>=dev-util/intltool-0.50.1
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/6b74bf58f1abeb84d35cf64241c760e26eaedaf9
	cd "${S}"
	rm -rf libgd
	git clone https://gitlab.gnome.org/GNOME/libgd
	cd libgd
	git checkout 643ad53887f6507a775c1f6e1cfbbbe4e939b04
	cd "${S}"

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/673b295a346774611412632f33a181b07ac00559
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/c0b1a7bbcd2f799546f628d64fd198d1afb10ee8
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/c375c64c5f3c917be14252d70cb15087e06053f8
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/2f47eca65c8ad6821376281a95e274d7787e42cc
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/de0858918b5e63dbc711f56d686c4a66b54f4007
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/020069220466ecb718fb18e00f3c4f0c31cc48da
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/b84e95e76d5e4d36ac6c1743d821684045f6168c
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/32c92435ffe0e7caf581459af6448894cf6fa8f0
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/74e6235ac72352a17843ab71bd7d0794d38b562f
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/80498fd382ae0aa091b6cbe12a6b96dfac07cbc8
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/af1a6933fc215235599c26109d80f41d5e870f17
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/946209d366a638cf0fbd4564f200869a00f8b516
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/35ea9386d2ad7f7cf043592462c0c3486892dee1
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/81a8fe5245119663f15edb32aebaf9ebe3be5306
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/8811ff5003a1129550b2f522a80cd302e91b05e8
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/bff3cc849ca05d6017620ee9849888e84a963a71
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/0c5e079ca1a3c323c6d1c99603ff06f10c535fed
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/d74e55ac1fb7c865c0d57368da5a94a45a60bcd6
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/fb7b8bbac5ef3591d2f940f3034a4390468ad01d
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/ea3610066fd643f8fb7c5317721ef1dcb0bd6325
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/389bb2e29786739b4a9d0199896f070e4ce85cdb
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/d3a8ba13bb6dfbdaa8a03f35c649c76f7b4b5252
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/3f4faecf8f718ea79de61b5fd9dfb51eac6fe571
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/226c8314915e48cfc5414d99fcabde50cdb75ab5
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/257a48d87dde3347814ecf5a9beee0607334022d
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/59540468524d86524f51bd08fd7702a38a0aa4b1
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/533c0f6a7207a0a72083734c16ec603784c50804
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/f55eefec841486a448a9f29cae7baaf1440c0b33
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/47f3c4bd81d644f1a13f853cdf54f44cb252f0d2
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/23a9d21a1a9be95b2bbf6626d80ede3b4a989fda
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/efcabf00020fe01fee75a3f55ae7a48e83de37d6
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/97cd9faec88615d71c99989cbab42fccd778cb9f
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/b077a604b0559620b77526a1b8b0875dd3ce0e30
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/1048328eae48ebb9de6be3a7286259d671c5034d
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/ef9698724a23be5d5f5233405324889bf25ca201
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/10b3a74b11433b7c70418a6fdde162bd8d42adaf
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/439b089fd9253d85654e121b886366a76223646d
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/9f937210ef8e3b13cdcb4fd962723063eb0419c4
	eapply "${FILESDIR}"/${PN}-3.17.1-tracker-do-not-forget-callback.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-both-id-and-name-have-to-be-non-null-ensure-they-are.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-instead-of-pixbufs-this-enables-crisp-rendering-of-overview-thumbnails.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-add-own-css-style-for-notebooks.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-empty-results-box-fix-blurry-icon-in-hi-dpi.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-manager-rework-how-the-manager-is-constructed.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-get-last-change-date-str-add-exceptions.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-note-view-on-color-changed-refer-to-emiting-note.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-note-view-disconnect-from-color-changed-at-finalize.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-fix-build-error.patch
	eapply "${FILESDIR}"/${PN}-3.17.4-make-icons-remove-obsolete-hi-scalable-note.patch
	eapply "${FILESDIR}"/${PN}-3.18.0-manager-get-item-path-handle-null.patch
	eapply "${FILESDIR}"/${PN}-3.19.3-make-zeitgeist-dependency-optional.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-bjb-editor-toolbar-moved-from-gtkpopover-to-gtkactionbar.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-bjb-editor-toolbar-moved-ui-definition-to-a-template-file.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-build-remove-dependancy-on-libedataserverui.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-bjb-bijiben-fixed-two-memory-leaks.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-editor-remove-unused-code-in-preparation-for-webkit2-port.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-port-to-webkit2.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-note-view-fix-background-color.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-fix-some-memory-leaks.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-bjb-bijiben-initialize-remaining-as-null.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-src-move-all-declarations-to-the-top-of-blocks.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-fix-some-memory-leaks2.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-note-view-segfault-back-button.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-biji-note-obj-added-const-qualifier-to-return-type.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-biji-webkit-editor-fixed-toggle-block-format-switch.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-biji-webkit-editor-fixed-mixed-declarations-and-code.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-note-obj-convert-webkit1-to-webkit2-notes.patch
	eapply "${FILESDIR}"/${PN}-3.24.0-editor-toolbar-remove-accelerators.patch
	eapply "${FILESDIR}"/${PN}-3.24.1-local-provider-remove-warning-about-trash-folder.patch
	eapply "${FILESDIR}"/${PN}-3.24.1-local-note-purge-memory-leak-when-deleting-note.patch
	eapply "${FILESDIR}"/${PN}-3.24.1-local-provider-purge-memory-leak.patch
	eapply "${FILESDIR}"/${PN}-3.24.1-serializer-purge-memory-leak-on-save.patch
	eapply "${FILESDIR}"/${PN}-3.24.1-window-base-transparent-main-window.patch
	eapply "${FILESDIR}"/${PN}-3.26.0-note-obj-critical-error-when-creating-a-new-note.patch
	eapply "${FILESDIR}"/${PN}-3.26.0-notebook-add-an-empty-method-for-delete.patch
	eapply "${FILESDIR}"/${PN}-3.26.0-main-view-crash-when-closing-app-with-empty-note.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-notes/commit/384dd61950cf40d2a0c2f9caf9ed0cb8bd2a4029
	eapply "${FILESDIR}"/${PN}-3.27.4-memo-provider-dont-add-custom-border-to-pixbuf.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-update-mimedb \
		--disable-zeitgeist
}
