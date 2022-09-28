import 'package:flutter/material.dart';

class DataPrivacyNotice extends StatelessWidget {
  const DataPrivacyNotice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("DATA PRIVACY NOTICE",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Text("Effectivity Date: December 17, 2020",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Alturas Supermarket Corporation.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " collectively known as Alturas Group of Companies (AGC), its respective subsidiaries, affiliates, associated companies, and jointly controlled entities are committed to protecting your personal data. We ensure that all systems and activities involving the collection and processing of your personal data are performed in accordance with the Data Privacy Act of 2012 (‘the Act’), its Implementing Rules and Regulations (‘IRR’), and other relevant policies, including issuances from the National Privacy Commission.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text("l. Scope",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "This Privacy Notice (“Notice”) applies to individuals who interact with ALTURUSH services as customers, vendors/suppliers, partners (riders/drivers and merchant partners), contractors and service provider (“You”).",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text("ll. Service Description",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "Alturas Group of Companies (AGC) is primarily engaged in variety of services including wholesale and retail of general merchandise with mall operation, supermarket, cinemas and food chains, agriculture, hatchery, manufacturing, and resort operations.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text(
              "We collect your personal data from various channels including:",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "DISTRIBUTION mobile sites/apps.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " Consumer-directed mobile sites or applications operated by or for DISTRIBUTION, such as smartphone apps.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "E-mail, text and other electronic messages.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " Interactions with electronic communications between you and DISTRIBUTION.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Offline registration forms.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " Printed or digital registration and similar forms that We collect via, for example, postal mail, in-store demos, contests, sampling activities, and other promotions, or events.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Advertising interactions.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " Interactions with our advertisements (e.g., if you interact with on one of our ads on a third party website, we may receive information about that interaction).",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Data from other sources.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " Third party social such as Facebook and Google, market research (if feedback not provided on an anonymous basis), third-party data aggregators, DISTRIBUTION promotional partners, public sources and data received when we acquire other companies.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text("lll. Personal Data Collected",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "We collect and process your personal in accordance with the Data Privacy Act of 2012 and with the specific purposes outlined in this Notice. Depending on how you interact with DISTRIBUTION, these data may include:",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text(
              "Personal Data:",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const Text("     a. Name",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text("     b. Birthday",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text("     c. Address",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text(
                "     d. Contact Details including Mobile and Home Phone Numbers",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.justify),
            const Text("     e. Store Name",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text("     f. DTI Cerftificate Number",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text("     g. Barangay Clearance",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const SizedBox(height: 5),
            const Text(
                "We may also collect aggregated information such as details of traffic data, computer or mobile device details, operating system, and browser type. This information does not identify any individual but is used for statistical purposes and improvement of our website.",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.justify),
            const SizedBox(height: 5),
            const Text("lV. Purposes of Personal Data Collected",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "We collect your personal data from various channels both online and offline for the following purposes:",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text("     1.	To process and ship your orders;",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text("     2.	To inform you of our goods and services;",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.justify),
            const Text(
                "     3.	To respond to your inquiries sent through different channels such as our websites, mobile app, email, and social media accounts. ",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.justify),
            const SizedBox(height: 5),
            const Text("V. Third-Party Sharing",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "We will only share your personal data when required by applicable laws and/or in response legal proceedings.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text(
              "If we need to disclose your personal data to our partners and affiliates, we will ensure that they are contractually bound by Data sharing Agreements (DSA) and/or Outsourcing Agreements.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text("Vl. Security of Your Personal Data",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "We take reasonable, legal, and adequate organizational, physical, and technical measures to keep your personal data confidential and secure.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "People who can access your Personal Data.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " Your personal data will be processed by our authorized staff or agents, on a need-to-know basis, depending on the specific purposes for which your personal have been collected.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Measures taken in operating environments.",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " We store your Personal Data in operating environments that use reasonable security measures to prevent unauthorized access. We follow reasonable standards to protect Personal Data.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text("Vll. Retention",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "We retrain your personal data for a minimum of (enter years), or if necessary, to satisfy its declared purposes. Also, we may retain certain information for regulatory compliance or as required by applicable laws.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text("Vlll. Your rights",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "In accordance with the Act, we allow to exercise the following rights:",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "a. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text: "Right to Be Informed. ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " We will inform you on how we collect and use your personal data through this Notice.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "b. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        "Right to Access or Obtain a Copy of your Personal Data. ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " You have the right to access and obtain a copy of your personal data in physical or electronic format, subject to our review and approval. You may send a request through our email address, dpo@alturasbohol.com.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "c. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text: "Right to Object. ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " You have the right to object if the personal data processing is based on consent our legitimate interest, subject to evaluation and approval. We may also retain your personal data for legal and compliance purposes.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "d. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text: "Right to Erasure or Blocking. ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " You have the right to erasure or withdraw your consent upon discovery and substantial proof that the personal data are incomplete, outdated, false, unlawfully obtained, used for unauthorized purposes, or are no longer necessary for the purposes which they were collected.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "e. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text: "Right to Rectification. ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " You have the right to rectify or correct any inaccuracies in your personal data.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "f. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text: "Right to file a complaint and be indemnified. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " If you feel that your personal has been breached and we are unable to resolve it satisfactorily, you have the right to file a complaint before the National Privacy Commission (NPC). You may also claim compensation for any damages sustained due to such inaccurate, incomplete, outdated, false, unlawfully obtained, or unauthorized use of personal information, upon judgement of the Law.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "g. ",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextSpan(
                    text: "Transmissibility Rights. ",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        " You may assign your rights as a data subject to your legal assignee or lawful heir, provided that legal evidence such as Special Power of Attorney is presented.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "If you wish to exercise any of the rights, you may send on email request to dpo@alturasbohol.com or call us at (038) 501-3000, between 8-5 PM, Mondays-Fridays.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text("lX. Changes to this Notice",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "We reserve the right to make changes to this Notice at any time. We highly encourage you to visit our websites or mobile apps to ensure that you are informed of the latest policies related to your personal data.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 5),
            const Text("X. Contact Us",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "For any questions, inquiries, or complaints on how we process your personal data, you may reach us through email at dpo@alturasbohol.com or call us at (038) 501-3000, between 8-5 PM, Mondays-Fridays.",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),
            const Text(
              "Data Privacy Officer:",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const Text(
              "dpo@alturasbohol.com",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const Text(
              "3F AGC Corporate Center",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
            const Text(
              "Dampas, Tagbilaran City, Bohol",
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
