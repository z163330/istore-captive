include $(TOPDIR)/rules.mk

PKG_NAME:=istore-captive
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=yourname
PKG_LICENSE:=GPL-3.0

# 告诉系统「不用编译源码」
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

define Package/istore-captive
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=iStoreOS 兑换码上网
  DEPENDS:=+nftables +jq +lua +luci-base +dnsmasq
  PKGARCH:=all
endef

define Package/istore-captive/description
  一机一码、扫码兑换、到期断网，零配置即用。
endef

# 空编译阶段
define Build/Compile
	true
endef

# 直接安装文件
define Package/istore-captive/install
	$(INSTALL_DIR) $(1)
	$(CP) ./src/* $(1)/
endef

$(eval $(call BuildPackage,istore-captive))