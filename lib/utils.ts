const rl = require("readline");
const { BigNumber } = require("@ethersproject/bignumber");

const BN = (n: any) => BigNumber.from(n.toString());

export const prompt = async (question: string) => {
  const r = rl.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false,
  });

  const answer = await new Promise((resolve, error) => {
    r.question(`${question} [y/n]: `, (answer: string) => {
      r.close();
      resolve(answer);
    });
  });

  if (answer !== "y" && answer !== "yes") {
    console.log("exiting...");
    process.exit(1);
  }

  console.log();
};

// pretty number
export const pn = (n: bigint | string) =>
  n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, "_");

export const getEnv = (name: string) => {
  const value = process.env[name];

  if (value === undefined || value === "") {
    throw new Error(`envrionment variable ${name} is not set`);
  }

  return value;
};
