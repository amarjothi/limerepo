To complete verification of thepollster.co.uk, you must add the following TXT record to the domain's DNS settings:

Domain Verification Record
A TXT record is a type of DNS record that provides additional information about your domain. The procedure for adding TXT records to your domain's DNS settings depends on who provides your DNS service. For general information, see Amazon SES Domain Verification TXT Records.

NOTE: If your DNS provider does not allow underscores in record names, you can omit _amazonses from the record name. To help you easily identify this record within your domain's DNS settings, you can optionally prefix the record value with amazonses:
Name    :     _amazonses.thepollster.co.uk
Type    :      TXT
Value   :      zBMxYLvOVspuWBL89qb0/oNQMHipnYut14cjjJP8XPs=



To enable DKIM signing for your domain (optional but recommended), you must add the following CNAME records to your domain's DNS settings:
DKIM Record Set
After you successfully add these CNAME records to your domain's DNS settings, Amazon SES will automatically detect the records and allow DKIM signing at that time. Verification of those records may take up to 72 hours.

NOTE: Unlike for domain verification, you cannot omit the underscore from _domainkey because the underscore is required by RFC 4871.
Name            :      zp5gxwmlm7vqvpk3q7yqmriq53k5scb4._domainkey.thepollster.co.uk
Type            :      CNAME
Value           :      zp5gxwmlm7vqvpk3q7yqmriq53k5scb4.dkim.amazonses.com


Name            :      ay5lpwhiqyuc2jmcyov4tpyxmkalzs5h._domainkey.thepollster.co.uk
Type            :      CNAME
Value           :      ay5lpwhiqyuc2jmcyov4tpyxmkalzs5h.dkim.amazonses.com

Name            :      5k55fzc2xeckceantzefvweafuiicru5._domainkey.thepollster.co.uk
Type            :      CNAME
Value           :      5k55fzc2xeckceantzefvweafuiicru5.dkim.amazonses.com


The following additional step applies to email receiving ONLY:
To automatically route your domain’s incoming mail to Amazon SES, add the following MX record to your domain’s DNS settings:
Email Receiving Record
The MX record for your domain tells email senders which mail server to contact to deliver your mail. For more information, see Publishing an MX Record for Amazon SES Email Receiving.

IMPORTANT: If you do not want to receive email through Amazon SES, you should NOT change your existing MX record (if you have one).
Name: thepollster.co.uk
Type: MX
Value: 10 inbound-smtp.us-east-1.amazonaws.com


