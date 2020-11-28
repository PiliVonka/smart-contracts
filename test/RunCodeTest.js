const RunCodeContract = artifacts.require("RunCode");


const truffleAssertions = require("truffle-assertions");
const { fromWei, toWei, getBalance, getStatusCodeFor } = require("../utils/ether");

contract("RunCode", accounts => {
  let RunCode = null;
  const oracle = accounts[0];
  const taskOwner = accounts[1];
  const taskSolver = accounts[2]; 

  // Constants
  const taskId = "id-1";
  const successReward = toWei("3", "ether"); // wins three ethers, if successfully solves the task
  const submissionPrice = toWei("1");  // pays 1 ethers for each submission
  const taskRegisterValue = toWei("10");
  const codeKey = "key-1";
  
  const outputAccounts = async () => {
    console.log({ oracle: await fromWei(await getBalance(oracle)) });
    console.log({ taskOwner: await fromWei(await getBalance(taskOwner)) });
    console.log({ taskSolver: await fromWei(await getBalance(taskSolver)) });
    console.log();
  };

  before(async () => {
    RunCode = await RunCodeContract.new(oracle);
    await outputAccounts();
  })

  it("registers task", async () => {
    await RunCode.registerTask(
      taskId,
      successReward, 
      submissionPrice,
      { from: taskOwner, value: taskRegisterValue }
    );
  });

  it("submits solution", async () => {
    await RunCode.addSubmission(
      taskId,
      codeKey, 
      { from: taskSolver, value: submissionPrice }
    );
  });

  it("puts the ACCEPTED result", async () => {
    await RunCode.putStatusResult(
      taskId,
      codeKey,
      getStatusCodeFor("ACCEPTED"),
      { from: oracle }
    );
  });
  
  it("checks task balance", async () => {
    const balance = (await RunCode.getBalance.call(
      taskId,
      { from: taskOwner }
    )).toString();
    console.log({ balance: fromWei(balance) });
    // assert(balance == taskRegisterValue);
  });

  after(async () => {
    await outputAccounts();
  });
});