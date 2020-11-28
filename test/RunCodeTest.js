const RunCodeContract = artifacts.require("RunCode");


const truffleAssertions = require("truffle-assertions");
const { fromWei, toWei, getBalance } = require("../utils/ether");

contract("RunCode", accounts => {
  let RunCode = null;
  const oracle = accounts[0];
  const taskOwner = accounts[1];
  const taskSolver = accounts[2]; 

  // Constants
  const taskId = "id-1";
  const successReward = toWei("3", "ether"); // wins three ethers, if successfully solves the task
  const submissionPrice = toWei("1");  // pays 1 ethers for each submission
  const codeKey = "key-1";
  
  const outputAccounts = async () => {
    console.log({ oracle: await fromWei(await getBalance(oracle)) });
    console.log({ taskOwner: await fromWei(await getBalance(taskOwner)) });
    console.log({ taskSolver: await fromWei(await getBalance(taskSolver)) });
  };

  before(async () => {
    RunCode = await RunCodeContract.new(oracle);
    await outputAccounts();
  })

  it("registers task", async () => {
    const res = await RunCode.registerTask(
      taskId,
      successReward, 
      submissionPrice,
      { from: taskOwner, value: toWei("10") }
    );
    // assert(res == true);
  });

  it("submits solution", async () => {
    const res = await RunCode.addSubmission(
      taskId,
      codeKey, 
      { from: taskSolver, value: toWei("1") }
    );
  });

  it("puts the result", async () => {
    const res = await RunCode.putStatusResult(
      taskId,
      codeKey,
      1,
      { from: oracle }
    );
  });

  after(async () => {
    await outputAccounts();
  });

});