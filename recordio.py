from pathlib import Path
from mxnet.recordio import MXRecordIO
import torch


def convert_to_

def test():
    record = MXRecordIO("/home/george/git/tmp/test.rec", 'r')

    for i in range(10):
        item = record.read()
        #print(item)
        print(i)

class RecordIODataset(torch.utils.data.IterableDataset):
        def __init__(self, start, end):
            super(MyIterableDataset).__init__()
            assert end > start, "this example code only works with end >= start"
            self.start = start
            self.end = end
        
        def __iter__(self):
            worker_info = torch.utils.data.get_worker_info()
            if worker_info is None:  # single-process data loading, return the full iterator
                iter_start = self.start
                iter_end = self.end
            else:  # in a worker process
                # split workload
                per_worker = int(math.ceil((self.end - self.start) / float(worker_info.num_workers)))
                worker_id = worker_info.id
                iter_start = self.start + worker_id * per_worker
                iter_end = min(iter_start + per_worker, self.end)
            return iter(range(iter_start, iter_end))
