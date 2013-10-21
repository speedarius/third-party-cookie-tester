third-party-cookie-tester
=========================

A basic Rails app to test web browsers' third-party cookie-blocking behavior.

I couldn't find authoritative information on how Safari treats 'third-party' cookies when set to "From visited" (mobile) or "Block from third-parties and advertisers" (desktop), so I created this simple rails app to test several scenarios.

How to use it
-------------

1. Create these fake hosts in your `/etc/hosts`:

        127.0.0.1 a.com b.com c.com a.b.com

2. Start the server: `rails -p <some_port> server`

3. Visit some of the following paths on any of the fake hosts:

* `/`
Visit the host without setting any cookies at all, not even a rails default session cookie. Shows the cookies that the browser sent to the server; this is a good way to tell if cookies have been set on a particular domain. I've found that various in-browser cookie-inspection tools are not good about excluding cookies that have been blocked via third-party cookie-blocking features.

* `/happy-cookie`
Visit the domain, setting a (first-party) from that host.

* `/third-party-script-tags`
Visit the domain and request (third-party) cookie-setting assets from each host via `<script>` tags.

* `/third-party-iframes`
Visit the domain and request (third-party) cookie-setting assets from each host via iframes.

* `/redirect?target=<url>`
Visit the domain and get redirected to the target URL.

* `/iframe?target=<url>`
Visit the domain and open an iframe to the target URL.

* `/open_window?target=<url>`
Visit the domain, then open a new window to the target URL.

For instance, `http://a.b.com:<some_port>/redirect?target=http://c.com:<some_port>/third_parties` will try to set third party cookies on each of `a.b.com`, `b.com`, and `c.com`, in the context of `c.com`, via redirect from `a.b.com`. To see if Safari accepts a third party cookie from `a.b.com` in this scenario, visit `http://a.b.com:5000` and look for the `third_party` cookie in the web inspector. (It doesn't.)

Findings
--------

I investigated the behavior in mobile Safari on iOS/iPhone version 6.1(10B141). My findings are consistent with Safari's algorithm for accepting third-party cookies (via `<script>` tags>) being the following:

When receiving a cookie from a secondary request for an asset:

1. `current_host` = the host in the address bar, regardless of whether it has been reached via redirect.
1. `third_party` = the host from which the third-party asset is requested
1. if `third_party` is on a subdomain of `current_host`, accept the cookie.
1. if `third_party` is the `current_host`, accept the cookie (technically not a third-party)
1. if `current_host` is on a subdomain for `third_party`, accept the cookie
1. if I already have a cookie on `third_party` (not a subdomain), accept the cookie
1. otherwise, reject the cookie

I would not, however, be surprised to learn that there are additional caveats and provisos not covered here.
