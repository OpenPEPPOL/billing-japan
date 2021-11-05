<?xml version="1.0" encoding="UTF-8"?>
<!--

            Copyright (C) 2020-2023 OpenPEPPOL AISBL

            Licensed under the Apache License, Version 2.0 (the "License");
            you may not use this file except in compliance with the License.
            You may obtain a copy of the License at

                    http://www.apache.org/licenses/LICENSE-2.0

            Unless required by applicable law or agreed to in writing, software
            distributed under the License is distributed on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
            See the License for the specific language governing permissions and
            limitations under the License.

-->
<!-- Schematron rules generated automatically by Validex Generator Midran ltd -->
<!-- Abstract rules for model -->
<!-- Timestamp: 2021-06-29 12:09:56 +0200 -->
<pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="PeppolReused">
    <let name="MIMECODE"
        value="tokenize('application/pdf image/png image/jpeg text/csv application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.oasis.opendocument.spreadsheet', '\s')"/>
    <let name="UNCL2005" value="tokenize('3 35 432', '\s')"/>
    <let name="UNCL5189"
        value="tokenize('41 42 60 62 63 64 65 66 67 68 70 71 88 95 100 102 103 104 105', '\s')"/>
    <let name="eaid"
        value="tokenize('0002 0007 0009 0037 0060 0088 0096 0097 0106 0130 0135 0142 0151 0183 0184 0190 0191 0192 0193 0195 0196 0198 0199 0200 0201 0202 0204 0208 0209 0210 0211 0212 0213 9901 9906 9907 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9955 9957', '\s')"/>
    <let name="profile" value="
        if (/*/cbc:ProfileID and matches(normalize-space(/*/cbc:ProfileID), 'urn:fdc:peppol.eu:2017:poacc:billing:([0-9]{2}):1.0')) then
        tokenize(normalize-space(/*/cbc:ProfileID), ':')[7]
        else
        'Unknown'"/>

    <rule context="cbc:TaxCurrencyCode">
        <assert id="PEPPOL-EN16931-R005"
            test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))"
            flag="fatal">Tax accounting currency code MUST be different from invoice currency code
            when provided.</assert>
    </rule>
    <rule
        context="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate">
        <assert id="PEPPOL-EN16931-F001"
            test="string-length(text()) = 10 and (string(.) castable as xs:date)" flag="fatal">A
            date MUST be formatted YYYY-MM-DD.</assert>
    </rule>
    <rule context="cac:Price/cac:AllowanceCharge">
        <assert id="PEPPOL-EN16931-R044" test="normalize-space(cbc:ChargeIndicator) = 'false'"
            flag="fatal">Charge on price level is NOT allowed. Only value 'false' allowed.</assert>
        <assert id="PEPPOL-EN16931-R046"
            test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)"
            flag="fatal">Item net price MUST equal (Gross price - item price discount) when gross
            price is provided.</assert>
    </rule>
    <rule
        context="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']">
        <assert id="PEPPOL-COMMON-R040"
            test="matches(normalize-space(), '^[0-9]+$') and u:gln(normalize-space())" flag="fatal"
            >GLN must have a valid format according to GS1 rules.</assert>
    </rule>
    <rule context="cbc:EmbeddedDocumentBinaryObject[@mimeCode]">
        <assert id="PEPPOL-EN16931-CL001" test="
                some $code in $MIMECODE
                    satisfies @mimeCode = $code" flag="fatal">Mime code must be according to
            subset of IANA code list.</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator = 'false']/cbc:AllowanceChargeReasonCode">
        <assert id="PEPPOL-EN16931-CL002" test="
                some $code in $UNCL5189
                    satisfies normalize-space(text()) = $code" flag="fatal">Reason code MUST
            be according to subset of UNCL 5189 D.16B.</assert>
    </rule>
    <rule context="cac:InvoicePeriod/cbc:DescriptionCode">
        <assert id="PEPPOL-EN16931-CL006" test="
                some $code in $UNCL2005
                    satisfies normalize-space(text()) = $code" flag="fatal">Invoice period
            description code must be according to UNCL 2005 D.16B.</assert>
    </rule>
    <rule context="cbc:EndpointID[@schemeID]">
        <assert id="PEPPOL-EN16931-CL008" test="
                some $code in $eaid
                    satisfies @schemeID = $code" flag="fatal">Electronic address identifier
            scheme must be from the codelist "Electronic Address Identifier Scheme"</assert>
    </rule>
    <rule context="cbc:InvoiceTypeCode">
        <assert id="PEPPOL-EN16931-P0100" test="
                $profile != '01' or (some $code in tokenize('380 383 386 393 82 80 84 395 575 623 780', '\s')
                    satisfies normalize-space(text()) = $code)" flag="fatal">Invoice type
            code MUST be set according to the profile.</assert>
    </rule>
    <rule context="cbc:CreditNoteTypeCode">
        <assert id="PEPPOL-EN16931-P0101" test="
                $profile != '01' or (some $code in tokenize('381 396 81 83 532', '\s')
                    satisfies normalize-space(text()) = $code)" flag="fatal">Credit note
            type code MUST be set according to the profile.</assert>
    </rule>
    <rule context="cac:AccountingCustomerParty/cac:Party">
        <assert id="PEPPOL-EN16931-R010" test="cbc:EndpointID" flag="fatal">Buyer electronic address
            MUST be provided</assert>
    </rule>
    <rule context="cac:InvoiceLine | cac:CreditNoteLine">
        <assert id="PEPPOL-EN16931-R121"
            test="not(cac:Price/cbc:BaseQuantity) or xs:decimal(cac:Price/cbc:BaseQuantity) &gt; 0"
            flag="fatal">Base quantity MUST be a positive number above zero.</assert>
    </rule>
    <!-- Accounting supplier -->
    <rule context="cac:AccountingSupplierParty/cac:Party">
        <assert id="PEPPOL-EN16931-R020" test="cbc:EndpointID" flag="fatal">Seller electronic
            address MUST be provided</assert>
    </rule>
    <rule
        context="ubl:Invoice/cac:AllowanceCharge | ubl:Invoice/cac:InvoiceLine/cac:AllowanceCharge | cn:CreditNote/cac:AllowanceCharge | cn:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge">
        <assert id="PEPPOL-EN16931-R043"
            test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'"
            flag="fatal">Allowance/charge ChargeIndicator value MUST equal 'true' or
            'false'</assert>
    </rule>


</pattern>
