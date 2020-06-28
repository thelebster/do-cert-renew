Runs the challenges and pushes the new certificate to DigitalOcean [certificates](https://www.digitalocean.com/docs/accounts/security/certificates/) for Load Balancers and Spaces. Built on top of CloudFlare API, LetsEncrypt and DigitalOcean API.

![alt text][screenshot]

Get your API key from https://www.cloudflare.com/a/account/my-account.

```
docker-compose -f docker-compose.yml up --build -d
```

Run script manually:
```
docker exec -it cert-manager ./renew.sh
```

Run renewal script directly:
```
export $(cat .env) && bash renew.sh
```
or
```
export $(cat .env) && docker run --rm -it \
    -e DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN \
    -e DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN \
    -e DOMAIN_NAME=$DOMAIN_NAME \
    -e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
    -e CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY \
    -e CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL \
    cert-manager ./renew.sh
```

* https://certbot.eff.org/docs/using.html#hooks
* https://www.digitalocean.com/docs/accounts/security/certificates/
* https://www.digitalocean.com/docs/spaces/how-to/customize-cdn-endpoint/
* https://www.digitalocean.com/docs/apis-clis/api/
* https://developers.digitalocean.com/documentation/v2/#certificates

[screenshot]: common/do-cert-manager.png "DigitalOcean: Certificates for Load Balancers and Spaces"
