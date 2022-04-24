*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587
Library             RPA.Robocorp.Vault
Library             RPA.Browser.Playwright
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.Browser.Selenium


*** Variables ***
${WEBSITES_CSV}=    websites.csv
@{ATTACHMENTS}=
...                 ${CURDIR}${/}output${/}theshout.com.png
...                 ${CURDIR}${/}output${/}wbmonline.com.png
...                 ${CURDIR}${/}output${/}winetitles.com.png
...                 ${CURDIR}${/}output${/}www.decanter.png
...                 ${CURDIR}${/}output${/}www.wineaustralia.png
...                 ${CURDIR}${/}output${/}www.winebusiness.png


*** Tasks ***
Take full page screenshots of given websites
    @{websites}=    Read Table From Csv    ${WEBSITES_CSV}    header=True
    FOR    ${website}    IN    @{websites}
        Run Keyword And Ignore Error
        ...    Take full page screenshot
        ...    ${website}[url]
        ...    ${website}[accept_cookies_selector]
        ...    ${website}[data_consent_selector]
    END
    Send email


*** Keywords ***
Take full page screenshot
    [Arguments]    ${url}    ${accept_cookies_selector}    ${data_consent_selector}
    New Page    ${url}
    Accept cookies and consents
    ...    ${accept_cookies_selector}
    ...    ${data_consent_selector}
    Scroll the page and wait until network is idle
    ${domain}=    Evaluate    urllib.parse.urlparse('${url}').netloc
    Take Screenshot    ${OUTPUT_DIR}${/}${domain}    fullPage=True

Accept cookies and consents
    [Arguments]    ${accept_cookies_selector}    ${data_consent_selector}
    Run Keyword And Ignore Error    Click    ${accept_cookies_selector}
    Run Keyword And Ignore Error    Click    ${data_consent_selector}

Scroll the page and wait until network is idle
    FOR    ${i}    IN RANGE    10
        Scroll By    vertical=100%
    END
    Run Keyword And Ignore Error    Wait Until Network Is Idle

Send email
    ${secret}=    Get Secret    mwgmailcredentials
    Authorize    account=${secret}[username]    password=${secret}[password]
    Send Message    sender=${secret}[username]
    ...    recipients=${secret}[recipient]
    ...    subject=Weekly wine news
    ...    html=False
    ...    body=Screenshots from the top wine news sites are included here
    ...    attachments=@{ATTACHMENTS}
