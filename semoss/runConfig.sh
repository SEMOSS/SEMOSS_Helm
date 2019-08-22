if [[ -z "${MONOLITH_COOKIE}" ]]; then
sh setMonolithCookie.sh
fi
if [ "$SECURITY_ON" = "true" ]
sh setSecurityOn.sh
fi
if [ "$SETSOCIAL" = "true" ]
then sh setSocialProps.sh
fi
