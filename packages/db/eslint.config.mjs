import { FlatCompat } from "@eslint/eslintrc";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

export default [
  ...compat.extends("plugin:@typescript-eslint/recommended", "plugin:prettier/recommended"),
  {
    files: ["*.ts"],
    rules: {
      // Reglas específicas para db
      "no-console": "off",
      "@typescript-eslint/no-explicit-any": "warn",
    },
  },
];
