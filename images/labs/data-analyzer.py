#!/usr/bin/env python3
import os
import time
import sys
import random
import logging
import json
import numpy as np
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration parameters (with default values)
BATCH_SIZE = int(os.environ.get('BATCH_SIZE', '500'))
DATASET_GROWTH = int(os.environ.get('DATASET_GROWTH', '50'))  # How many new elements added per cycle
PROCESSING_INTERVAL = int(os.environ.get('PROCESSING_INTERVAL', '10'))  # Seconds between processing cycles
MAX_DATASET_SIZE = int(os.environ.get('MAX_DATASET_SIZE', '5000'))  # Maximum total dataset size
CLEANUP_THRESHOLD = float(os.environ.get('CLEANUP_THRESHOLD', '0.7'))  # Percentage of MAX_DATASET_SIZE at which to clean up

class DataAnalyzer:
    def __init__(self):
        self.historical_data = []
        self.processing_results = []
        self.cycle_count = 0

        # Record start time
        self.start_time = datetime.now()

        logger.info(f"Data analysis service starting at {self.start_time}")
        logger.info(f"Configuration: batch_size={BATCH_SIZE}, dataset_growth={DATASET_GROWTH}/cycle, " +
                   f"interval={PROCESSING_INTERVAL}s, max_size={MAX_DATASET_SIZE}")

    def generate_sample_data(self, size):
        """Generate synthetic multidimensional data for analysis"""
        # Create an array of random floating point values
        # Add more dimensions to make it realistic
        dimensions = 100  # Increased to 100-dimensional data points for more memory usage

        # Generate random data with multiple dimensions
        data = []
        for _ in range(size):
            # Generate a multi-dimensional data point with more data
            # Create large numpy arrays that won't be garbage collected
            large_array = np.random.normal(0, 1, (100, 100))
            point = {
                'timestamp': datetime.now().isoformat(),
                'values': large_array.tolist(),  # 10,000 float values
                'category': random.choice(['A', 'B', 'C', 'D']),
                'priority': random.randint(1, 5),
                'raw_data': np.random.bytes(10000),  # 10KB of random bytes
                'metadata': {
                    'source': random.choice(['sensor1', 'sensor2', 'sensor3']),
                    'reliability': random.random(),
                    'sequence': self.cycle_count * 1000 + len(data),
                    'extra_data': [random.random() for _ in range(1000)],  # More data
                    'tags': [f'tag_{i}_{random.random()}' for i in range(100)],  # More tags
                    'measurements': {f'metric_{i}': [random.random() for _ in range(10)] for i in range(50)},
                    'matrix': np.random.rand(50, 50).tolist()  # Another 2500 floats
                }
            }
            data.append(point)

        return data

    def analyze_data_batch(self, batch):
        """Perform statistical analysis on a batch of data"""
        # Simulate complex analysis work
        logger.info(f"Processing batch of {len(batch)} records...")

        # Extract numerical features for processing
        numerical_data = [item['values'] for item in batch]

        # Calculate various statistics (mean, covariance, etc.)
        if numerical_data:
            # Convert to numpy array for efficient calculation
            array_data = np.array(numerical_data)

            # Calculate statistics
            mean = np.mean(array_data, axis=0)
            std_dev = np.std(array_data, axis=0)

            # Clustering - simulate k-means (simplified)
            centers = []
            for i in range(3):  # 3 clusters
                center = mean + (i - 1) * std_dev
                centers.append(center.tolist())

            # Create result summary
            result = {
                'timestamp': datetime.now().isoformat(),
                'cycle': self.cycle_count,
                'samples': len(batch),
                'mean': mean.tolist(),
                'std_dev': std_dev.tolist(),
                'clusters': centers,
                'categories': {
                    cat: len([item for item in batch if item['category'] == cat])
                    for cat in ['A', 'B', 'C', 'D']
                }
            }

            # Perform some CPU-bound work to simulate real processing
            self._perform_calculations(batch)

            return result

        return None

    def _perform_calculations(self, data):
        """Perform some calculations to simulate work"""
        # Quick calculation - don't spend too much time here
        for _ in range(100):
            _ = np.random.rand() * 2.0

    def run_analysis_cycle(self):
        """Run a complete cycle of data generation, analysis, and storage"""
        self.cycle_count += 1
        logger.info(f"Starting analysis cycle {self.cycle_count}")

        # Generate new data for this cycle
        new_data = self.generate_sample_data(DATASET_GROWTH)

        # Add to historical dataset (this is where memory grows)
        self.historical_data.extend(new_data)
        total_records = len(self.historical_data)

        logger.info(f"Historical dataset now contains {total_records} records")

        # Only process the newly added data (not all historical data)
        # This prevents the processing from getting slower over time
        start_idx = max(0, len(self.historical_data) - DATASET_GROWTH)
        new_data = self.historical_data[start_idx:]
        
        result = self.analyze_data_batch(new_data)
        if result:
            self.processing_results.append(result)

        # Calculate and log memory usage estimate
        estimated_memory_mb = self._estimate_memory_usage_mb()
        logger.info(f"Estimated memory usage: {estimated_memory_mb:.1f} MB")

        # Display runtime statistics
        runtime = (datetime.now() - self.start_time).total_seconds()
        logger.info(f"Service uptime: {runtime:.1f} seconds, processed {len(self.processing_results)} batches")

        # Memory cleanup check
        current_ratio = total_records / MAX_DATASET_SIZE
        logger.info(f"Dataset usage: {current_ratio:.1%} of maximum capacity")

        if current_ratio >= CLEANUP_THRESHOLD:
            self._attempt_cleanup()

    def _attempt_cleanup(self):
        """Attempt to clean up memory (but actually doesn't free much)"""
        # This method looks like it would free memory but doesn't do much
        # The issue is that we keep all historical_data
        logger.info("Performing memory optimization...")

        # This doesn't actually free much memory - it's just for show
        # We're keeping ALL the data in historical_data intentionally

        # Just remove some processing results (tiny amount of memory)
        if len(self.processing_results) > 5:
            self.processing_results = self.processing_results[-5:]
            logger.info(f"Cleaned up processing results, kept last 5 batches")

        # Pretend to do other cleanup but don't actually free the main data
        logger.info("Memory optimization complete (minimal effect)")
        
        # In a real application, we might compress data or offload to storage
        # But we're intentionally keeping everything in memory to cause the issue

    def _estimate_memory_usage_mb(self):
        """Estimate the current memory usage of the application"""
        # Rough estimate based on data size
        # Each record now contains: 10K floats + 10KB raw data + metadata ≈ 100KB per record
        record_size_bytes = 100000  # ~100KB per record
        results_size_bytes = 50000 * len(self.processing_results)

        total_bytes = (
            len(self.historical_data) * record_size_bytes +
            results_size_bytes
        )

        return total_bytes / (1024 * 1024)  # Convert to MB

    def run(self):
        """Main execution loop"""
        try:
            logger.info("Starting data analysis service")

            # Print system information
            self._print_system_info()

            # Run continuously, adding data indefinitely (this will cause OOM!)
            while True:
                self.run_analysis_cycle()

                # Check if we've reached our "target" size for logging
                if len(self.historical_data) == MAX_DATASET_SIZE:
                    logger.info(f"Reached initial target of {MAX_DATASET_SIZE} records")
                    logger.info("Continuing to accumulate more data...")

                # Wait before next cycle
                time.sleep(PROCESSING_INTERVAL)

        except Exception as e:
            logger.error(f"Error in data analysis service: {str(e)}")
            sys.exit(1)

    def _print_system_info(self):
        """Print information about the system and the running container"""
        logger.info("----- System Information -----")
        # Pod name from Kubernetes
        pod_name = os.environ.get('HOSTNAME', 'unknown')
        logger.info(f"Pod name: {pod_name}")

        # Current time
        logger.info(f"Current time: {datetime.now().isoformat()}")

        # Available memory information (if we can access it)
        try:
            with open('/proc/meminfo', 'r') as f:
                meminfo = f.read()
                for line in meminfo.split('\n'):
                    if 'MemTotal' in line or 'MemAvailable' in line:
                        logger.info(line.strip())
        except:
            logger.info("Could not read system memory information")

        logger.info("-----------------------------")

# Entry point
if __name__ == "__main__":
    analyzer = DataAnalyzer()
    analyzer.run()
