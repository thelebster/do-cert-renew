Allow to keep custom DigitalOcean [certificates](https://www.digitalocean.com/docs/accounts/security/certificates/) for Load Balancers and Spaces updated. Automation for [replacing SSL certificate for Spaces CDN](https://www.digitalocean.com/community/questions/replacing-ssl-certificate-for-spaces-cdn). Build on top of CloudFlare API, LetsEncrypt and DigitalOcean API.

Get your API key from https://www.cloudflare.com/a/account/my-account.

```
docker-compose -f docker-compose.yml up --build -d
```

* https://certbot.eff.org/docs/using.html#hooks
* https://www.digitalocean.com/docs/accounts/security/certificates/
* https://www.digitalocean.com/docs/spaces/how-to/customize-cdn-endpoint/
* https://www.digitalocean.com/docs/apis-clis/api/
* https://developers.digitalocean.com/documentation/v2/#certificates
