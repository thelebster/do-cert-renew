Runs the challenges and pushes the new certificate to DigitalOcean [certificates](https://www.digitalocean.com/docs/accounts/security/certificates/) for Load Balancers and Spaces. Built on top of CloudFlare API, LetsEncrypt and DigitalOcean API.

![alt text][screenshot]

Get your API key from https://www.cloudflare.com/a/account/my-account.

Pull the latest version from https://hub.docker.com/r/thelebster/do-cert-renew:
```
docker pull thelebster/do-cert-renew
```

Run:
```
export $(cat .env) && docker run -d \
    --name cert-manager \
    -e DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN \
    -e DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN \
    -e DOMAIN_NAME=$DOMAIN_NAME \
    -e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
    -e CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY \
    -e CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL \
    thelebster/do-cert-renew
```

Run renewal script manually:
```
export $(cat .env) && docker run --rm -it \
    -e DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN \
    -e DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN \
    -e DOMAIN_NAME=$DOMAIN_NAME \
    -e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
    -e CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY \
    -e CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL \
    thelebster/do-cert-renew ./renew.sh
```

### Run with docker-compose
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

* https://certbot.eff.org/docs/using.html#hooks
* https://www.digitalocean.com/docs/accounts/security/certificates/
* https://www.digitalocean.com/docs/spaces/how-to/customize-cdn-endpoint/
* https://www.digitalocean.com/docs/apis-clis/api/
* https://developers.digitalocean.com/documentation/v2/#certificates

[screenshot]: https://s.lebster.me/github/do-cert-manager.png "DigitalOcean: Certificates for Load Balancers and Spaces"
