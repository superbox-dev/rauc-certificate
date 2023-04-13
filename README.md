# RAUC certificate with Easy RSA

Init PKI and copy vars.example (Edit this `vars` file to customise the settings for your PKI) to vars.

```shell
$ easyrsa init-pki
$ cp vars.example pki/vars
```

Build CA with:

```shell
$ easyrsa build-ca
```

