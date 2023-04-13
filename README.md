# RAUC certificate with Easy RSA

How to setup a Simple CA for your [RAUC CA configuration](https://rauc.readthedocs.io/en/latest/advanced.html#ca-configuration).

Initialize PKI and copy vars.example (Edit this `vars` file to customise the settings for your PKI) to vars.

```shell
$ easyrsa init-pki
$ cp vars.example pki/vars
```

Build CA with:

```shell
$ easyrsa build-ca nopass
```

You now have two important files: `pki/ca.crt` and `private/ca.key` which make up the public and private components of a Certificate Authority.

Copy the public certificate file `pki/ca.crt` to `/etc/rauc/keyring.pem`
