include $(TOPDIR)/rules.mk

PKG_NAME:=istore-captive
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/istore-captive
  SECTION:=net
  CATEGORY:=Network
  TITLE:=iStoreOS 兑换码上网插件
  DEPENDS:=+nftables +jq +lua5.1 +luci-base +dnsmasq
  PKGARCH:=all
endef

define Package/istore-captive/description
  一机一码、扫码兑换、到期断网，零配置即用。
endef

define Package/istore-captive/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./src/files/etc/uci-defaults/99-captive $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/etc/captive
	$(INSTALL_DIR) $(1)/etc/nftables.d
	$(INSTALL_DATA) ./src/files/nftables.d/99-captive.nft $(1)/etc/nftables.d/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./src/files/usr/bin/cp_codegen.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./src/files/usr/bin/cp_daemon.sh $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/www
	$(INSTALL_DATA) ./src/files/www/cp.html $(1)/www/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./src/files/usr/lib/lua/luci/controller/cp.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./src/files/usr/lib/lua/luci/model/cbi/cp_codes.lua $(1)/usr/lib/lua/luci/model/cbi/
endef

define Package/istore-captive/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/etc/init.d/cp_daemon enable
/etc/init.d/cp_daemon start
exit 0
endef

define Package/istore-captive/prerm
#!/bin/sh
/etc/init.d/cp_daemon stop
/etc/init.d/cp_daemon disable
nft delete table inet cp 2>/dev/null
exit 0
endef

$(eval $(call BuildPackage,istore-captive))