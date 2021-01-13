# DigitalOcean Spaces certificate renewal manager

Runs the challenges and pushes the new certificate to DigitalOcean [certificates](https://www.digitalocean.com/docs/accounts/security/certificates/) for Spaces. Built on top of CloudFlare API, LetsEncrypt and DigitalOcean API.

![alt text][screenshot]

**To make custom subdomain work, you need to [create a CNAME record](https://www.digitalocean.com/docs/networking/dns/how-to/manage-records/#cname-records) pointing to your Space.**

Current implementation use CloudFlare API to manage DNS for a custom domain, you need to [get your API key](https://www.cloudflare.com/a/account/my-account).

## Usage 

Pull the latest version from https://hub.docker.com/r/thelebster/do-cert-renew:
```
docker pull thelebster/do-cert-renew
```

To run renewal for multiple CDN endpoints and domains, provide colon-separated pairs within `SPACES` env variable, in form of `DIGITALOCEAN_CDN_ORIGIN,CUSTOM_DOMAIN_NAME;DIGITALOCEAN_CDN_ORIGIN,CUSTOM_DOMAIN_NAME;...`.

```
SPACES=example.ams3.digitaloceanspaces.com,cdn.example.com:example.ams3.digitaloceanspaces.com,public.example.com
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

Build with a docker-compose and run manually:
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

Run manually with an extra args:
```
export $(cat .env) && docker run --rm -it \
    -e DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN \
    -e DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN \
    -e DOMAIN_NAME=$DOMAIN_NAME \
    -e LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL \
    -e CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY \
    -e CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL \
    -e CERTBOT_ARGS="-v --dry-run --force-renewal" \
    cert-manager ./renew.sh
```

## References

* https://certbot.eff.org/docs/using.html#hooks
* https://www.digitalocean.com/docs/accounts/security/certificates/
* https://www.digitalocean.com/docs/spaces/how-to/customize-cdn-endpoint/
* https://www.digitalocean.com/docs/apis-clis/api/
* https://developers.digitalocean.com/documentation/v2/#certificates
* https://developers.digitalocean.com/documentation/v2/#cdn-endpoints

## Changelog

**Jan 13, 2021**
* Allow renewal for multiple Spaces (CDN endpoints).

**July 2, 2020**
* Allow pass extra arguments, like `-vvv`, `--dry-run`, `--force-renewal` etc. to certbot using `CERTBOT_ARGS` env variable.

[screenshot]: https://s.lebster.me/github/do-cert-manager.png "DigitalOcean: Certificates for Load Balancers and Spaces"
