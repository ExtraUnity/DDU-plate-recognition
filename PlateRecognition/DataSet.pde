class DataSet {

  final int INPUT_SIZE;
  final int OUTPUT_SIZE;
  ArrayList<double[][]> data = new ArrayList<double[][]>();

  DataSet(int INPUT_SIZE, int OUTPUT_SIZE) {
    this.INPUT_SIZE = INPUT_SIZE;
    this.OUTPUT_SIZE = OUTPUT_SIZE;
  }

  void addData(double[] input, double[] target) {
    if (input.length == INPUT_SIZE && target.length == OUTPUT_SIZE) {
      data.add(new double[][]{input, target});
    }
  }

  DataSet getBatch(int size) {
    if (size > 0 && size<=this.data.size()) {

      DataSet batch = new DataSet(this.INPUT_SIZE, this.OUTPUT_SIZE);

      int[] indexes = getRandomValues(0,this.data.size(),size);
      for(int i : indexes) {
        batch.data.add(this.data.get(i));
      }

      return batch;
    }
    return this;
  }


  double[] getInput(int i) {
    return data.get(i)[0];
  }

  double[] getOutput(int i) {
    return data.get(i)[1];
  }
}
