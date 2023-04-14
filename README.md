# RAUC Simple CA

A Tool to generate a simple CA for [RAUC](https://rauc.readthedocs.io/).

## Arguments

| Argument                     | Description                                            |
|------------------------------|--------------------------------------------------------|
| `--build-root-ca [ORG] [CA]` | Build root CA and directory structure for certificates |
| ` --create-signing-key [CN]` | Create code signing key                                |

## Usage

First generate a root CA and the directory structure for certifcates with:

```shell
$ ./openssl-ca.sh --build-root-ca "Example CA" "RAUC CA"
```

Copy `openssl-ca/root/ca.cert.pem` to `/etc/rauc/keyring.pem`.

Generate a new siging key with:

```shell
$ ./openssl-ca.sh --create-signing-key "Common Name"
```

Use `openssl-ca/mh.cert.pem` and `openssl-ca/private/mh.key.pem` for [creating RAUC bundles](https://rauc.readthedocs.io/en/latest/using.html#creating-bundles). 
