# Copyright (C) 2023 Findlay Feng <i@fengch.me>

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=2.6.1
PKG_RELEASE:=3

GO_PKG:=github.com/apernet/hysteria

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://$(GO_PKG).git
PKG_MIRROR_HASH:=65489fdac0a765d93fe87b6fc018146e8c35b0bb9f92cddfb8715486ac8a5c65
PKG_SOURCE_VERSION:=app/v$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Findlay Feng <i@fengch.me>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-values.mk

GO_PKG_BUILD_PKG=$(GO_PKG)/app/v2
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG_BUILD_PKG)/cmd.appToolchain=$(shell go version | sed -e 's|go version ||' -e 's| |_|' ) \
	$(GO_PKG_BUILD_PKG)/cmd.appDate=$(shell date -u '+%FT%TZ') \
	$(GO_PKG_BUILD_PKG)/cmd.appVersion=v$(PKG_VERSION) \
	$(GO_PKG_BUILD_PKG)/cmd.appCommit=$(PKG_SOURCE_VERSION) \
	$(GO_PKG_BUILD_PKG)/cmd.appPlatform=linux \
	$(GO_PKG_BUILD_PKG)/cmd.appType=release \
	$(GO_PKG_BUILD_PKG)/cmd.appArch=$(GO_ARCH)

include $(GO_INCLUDE_DIR)/golang-package.mk

define Package/$(PKG_NAME)/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	DEPENDS:=+ca-bundle
	TITLE:=A feature-packed proxy & relay tool optimized for lossy
	URL:=https://hysteria.network
endef

define Package/$(PKG_NAME)
	$(call Package/$(PKG_NAME)/Default)
	VARIANT:=base
	DEPENDS+=$(GO_ARCH_DEPENDS)
	PROVIDES:=$(PKG_NAME)-bin
endef

define Package/$(PKG_NAME)-avx
	$(call Package/$(PKG_NAME)/Default)
	TITLE+= with avx
	VARIANT:=avx
	DEPENDS+=@(x86_64)
	PROVIDES:=$(PKG_NAME)-bin
endef

define Package/$(PKG_NAME)-configs
	$(call Package/$(PKG_NAME)/Default)
	TITLE:=configs
	PKGARCH:=all
	USERID:=hysteria=102:hysteria=102
endef

define Package/$(PKG_NAME)-clientd
	$(call Package/$(PKG_NAME)/Default)
	TITLE:=client init scripts
	PKGARCH:=all
	DEPENDS:=$(PKG_NAME)-bin +$(PKG_NAME)-configs
	PROVIDES:=$(PKG_NAME)-scripts
endef

define Package/$(PKG_NAME)-serverd
	$(call Package/$(PKG_NAME)/Default)
	TITLE:=server init scripts
	PKGARCH:=all
	DEPENDS:=$(PKG_NAME)-bin +$(PKG_NAME)-configs
	PROVIDES:=$(PKG_NAME)-scripts
endef

define Package/$(PKG_NAME)/description
	Hysteria is a feature-packed proxy & relay tool optimized for lossy,
	unstable connections (e.g. satellite networks, congested public Wi-Fi,
	connecting to foreign servers from China) powered
	by a customized protocol based on QUIC.
endef

define Package/$(PKG_NAME)-avx/description
	$(call Package/$(PKG_NAME)/description)
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/sysctl.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/app $(1)/usr/bin/$(PKG_NAME)

	$(INSTALL_CONF) ./files/sysctl-hysteria.conf $(1)/etc/sysctl.d/11-$(PKG_NAME).conf
endef

define Package/$(PKG_NAME)-avx/install
	$(call Package/$(PKG_NAME)/install,$(1))
endef

define Package/$(PKG_NAME)-configs/install
	$(INSTALL_DIR) \
		$(1)/etc/config \
		$(1)/etc/capabilities

	$(INSTALL_CONF) ./files/hysteria.json $(1)/etc/capabilities/$(PKG_NAME).json
	$(INSTALL_CONF) ./files/hysteria.config $(1)/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)-serverd/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) ./files/hysteria-serverd.init $(1)/etc/init.d/$(PKG_NAME)-serverd
	$(INSTALL_DATA) ./files/configs/server.yaml $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)-clientd/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/usr/share/$(PKG_NAME)/bin \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) ./files/hysteria.init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_BIN) ./files/bin/hysteria-tproxy.sh $(1)/usr/share/$(PKG_NAME)/bin/set-tproxy
	$(INSTALL_DATA) ./files/configs/client.yaml $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)-configs/conffiles
/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)-serverd/conffiles
/etc/${PKG_NAME}/
endef

define Package/$(PKG_NAME)-clientd/conffiles
/etc/${PKG_NAME}/
endef

ifeq ($(BUILD_VARIANT),avx)
	GO_AMD64:=v3
endif

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-avx))
$(eval $(call BuildPackage,$(PKG_NAME)-configs))
$(eval $(call BuildPackage,$(PKG_NAME)-clientd))
$(eval $(call BuildPackage,$(PKG_NAME)-serverd))
