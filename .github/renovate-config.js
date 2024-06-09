// SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
//
// SPDX-License-Identifier: MPL-2.0

module.exports = {
    branchPrefix: "update-renovate/",
    gitAuthor: "Renovate Bot <bot@renovateapp.com>",
    onboarding: false,
    platform: "github",
    extends: ["config:recommended", "docker:enableMajor"],
    packageRules: [
        {
            "matchDatasources": ["docker"],
            "versioning": "semver"
        },
    ],
};
