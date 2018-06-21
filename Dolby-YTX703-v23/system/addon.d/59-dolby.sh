#!/sbin/sh

. /tmp/backuptool.functions

list_files() {
cat <<EOF
lib/libdlbdapstorage.so
lib/libhwdaphal.so
lib/libstagefright_soft_ddpdec.so
lib/soundfx/libswdax.so
lib64/libhwdaphal.so
etc/dolby/dax-default.xml
priv-app/Ax/Ax.apk
priv-app/AxUI/AxUI.apk
addon.d/59-dolby.sh
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      restore_file $S/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    UUID="9d4921da-8225-4f29-aefa-6e6f69726861"
    CONF="/system/etc/audio_effects.conf"
    # Removing AudioFX & CMAudioService
    rm -R /system/priv-app/AudioFX/;
    rm -R /system/priv-app/CMAudioService/;
    # Removing old configs
    sed -i 'H;1h;$!d;x; s/[[:blank:]]*dax {[^{}]*\({[^}]*}[^{}]*\)*}[[:blank:]]*\n//g' $CONF;
    # Patching audio_effects.conf
    sed -i 's/^effects {/effects {\n  dax {\n    library dax\n    uuid '$UUID'\n  }/g' $CONF;
    sed -i 's/^libraries {/libraries {\n  dax {\n    path \/system\/lib\/soundfx\/libswdax.so\n  }/g' $CONF;
  ;;
  post-restore)
    # Stub
  ;;
esac
