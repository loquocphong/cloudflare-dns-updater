# Cloudflare-dns-updater
A bash script get your public IP Address and use it to update your exitsting DNS Record on Cloudflare.
# Use
- rename file config_default.ini to config.ini
- edit file config.ini. replace YOUR_AccessToken, YOUR_ZoneID, YOUR_DNSRecordName with your data
    AccessToken = YOUR_AccessToken
    ZoneID = YOUR_ZoneID
    DNSRecordName = YOUR_DNSRecordName
- run command : sh cloudflare-dns-updater.sh
