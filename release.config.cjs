const branchName = process.env.GITHUB_REF_NAME || "master";
const prereleaseId = branchName
  .toLowerCase()
  .replace(/[^a-z0-9-]+/g, "-")
  .replace(/^-+|-+$/g, "") || "dev";

const branches =
  branchName === "master"
    ? ["master"]
    : [
        "master",
        {
          name: branchName,
          prerelease: prereleaseId,
        },
      ];

module.exports = {
  branches,
  tagFormat: "v${version}",
  plugins: [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    [
      "@semantic-release/github",
      {
        assets: [
          {
            path: "out/*.bin",
            label: "Firmware binary",
          },
        ],
      },
    ],
  ],
};
