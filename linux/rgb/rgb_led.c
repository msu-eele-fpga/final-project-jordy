#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/io.h>
#include <linux/mutex.h>       
#include <linux/miscdevice.h>  
#include <linux/types.h>       
#include <linux/fs.h> 
#include <linux/kstrtox.h>           

#define LED_RED_OFFSET              0x0
#define LED_GREEN_OFFSET            0x04
#define LED_BLUE_OFFSET             0x08
#define SW_REGISTER_OFFSET          0x0C
#define PERIOD_OFFSET               0x10
#define LED_CTRL_OFFSET             0x14

#define SPAN 			0x20    // final project SPAN

/*
*	STATE CONTAINTER
*/
struct rgb_control_dev {
    void __iomem *base_addr;
    void __iomem *led_control;
    void __iomem *period;
    void __iomem *led_red;
    void __iomem *led_blue;
    void __iomem *led_green;
    void __iomem *switch_reg;
    struct miscdevice miscdev;
    struct mutex lock; 
};
/*
*	FUNCTIONS
*/

static ssize_t rgb_control_read(struct file *file, char __user *buf,
                                 size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    struct rgb_control_dev *priv = container_of(file->private_data,
                                                 struct rgb_control_dev, miscdev);

    if (*offset < 0) 
    {
        return -EINVAL;
    }
    if (*offset >= SPAN) 
    {
        return 0;
    }
    if ((*offset % 0x4) != 0) 
    {
        pr_warn("rgb_control_read: unaligned access\n");
        return -EFAULT;
    }

    val = ioread32(priv->base_addr + *offset);

    ret = copy_to_user(buf, &val, sizeof(val));
    if (ret == sizeof(val)) {
        pr_warn("rgb_control_read: nothing copied\n");
        return -EFAULT;
    }

    *offset += sizeof(val);

    return sizeof(val);
}

static ssize_t rgb_control_write(struct file *file, const char __user *buf,
                                  size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    struct rgb_control_dev *priv = container_of(file->private_data,
                                                 struct rgb_control_dev, miscdev);

    if (*offset < 0) 
    {
        return -EINVAL;
    }
    if (*offset >= SPAN) 
    {
        return 0;
    }
    if ((*offset % 0x4) != 0) 
    {
        pr_warn("rgb_control_write: unaligned access\n");
        return -EFAULT;
    }

    mutex_lock(&priv->lock);

    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret != sizeof(val)) 
    {
        iowrite32(val, priv->base_addr + *offset);
        *offset += sizeof(val);
        ret = sizeof(val);
    } 
    else 
    {
        pr_warn("rgb_control_write: nothing copied from user space\n");
        ret = -EFAULT;
    }

    mutex_unlock(&priv->lock);
    return ret;
}

static ssize_t led_red_show(struct device *dev,
                            struct device_attribute *attr, char *buf)
{
    u32 led_red;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    led_red = ioread32(priv->led_red);

    return scnprintf(buf, PAGE_SIZE, "%u\n", led_red);
}

static ssize_t led_red_store(struct device *dev,
                             struct device_attribute *attr,
                             const char *buf, size_t size)
{
    u32 led_red;
    int ret;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &led_red);
    if (ret < 0) 
    {
        return ret;
    }

    iowrite32(led_red, priv->led_red);

    return size;
}
///////////////////////////
static ssize_t led_green_show(struct device *dev,
                            struct device_attribute *attr, char *buf)
{
    u32 led_green;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    led_green = ioread32(priv->led_green);

    return scnprintf(buf, PAGE_SIZE, "%u\n", led_green);
}

static ssize_t led_green_store(struct device *dev,
                             struct device_attribute *attr,
                             const char *buf, size_t size)
{
    u32 led_green;
    int ret;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &led_green);
    if (ret < 0) 
    {
        return ret;
    }

    iowrite32(led_green, priv->led_green);

    return size;
}
//////////////////////////////////
static ssize_t led_blue_show(struct device *dev,
                            struct device_attribute *attr, char *buf)
{
    u32 led_blue;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    led_blue = ioread32(priv->led_blue);

    return scnprintf(buf, PAGE_SIZE, "%u\n", led_blue);
}

static ssize_t led_blue_store(struct device *dev,
                             struct device_attribute *attr,
                             const char *buf, size_t size)
{
    u32 led_blue;
    int ret;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &led_blue);
    if (ret < 0) 
    {
        return ret;
    }

    iowrite32(led_blue, priv->led_blue);

    return size;
}
//////////////////////////////////////
static ssize_t period_show(struct device *dev,
                                struct device_attribute *attr, char *buf)
{
    u32 period;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    period = ioread32(priv->period);

    return scnprintf(buf, PAGE_SIZE, "%u\n", period);
}

static ssize_t period_store(struct device *dev,
                                 struct device_attribute *attr,
                                 const char *buf, size_t size)
{
    u32 period;
    int ret;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &period);
    if (ret < 0) 
    {
        return ret;
    }

    iowrite32(period, priv->period);

    return size;
}
static ssize_t led_control_show(struct device *dev,
                                struct device_attribute *attr, char *buf)
{
    u32 led_control;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    led_control = ioread32(priv->led_control);

    return scnprintf(buf, PAGE_SIZE, "%u\n", led_control);
}

static ssize_t led_control_store(struct device *dev,
                                 struct device_attribute *attr,
                                 const char *buf, size_t size)
{
    u32 led_control;
    int ret;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &led_control);
    if (ret < 0) 
    {
        return ret;
    }

    iowrite32(led_control, priv->led_control);

    return size;
}

static ssize_t switch_reg_show(struct device *dev,
                                struct device_attribute *attr, char *buf)
{
    u32 switch_reg;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    switch_reg = ioread32(priv->switch_reg);

    return scnprintf(buf, PAGE_SIZE, "%u\n", switch_reg);
}

static ssize_t switch_reg_store(struct device *dev,
                                 struct device_attribute *attr,
                                 const char *buf, size_t size)
{
    u32 switch_reg;
    int ret;
    struct rgb_control_dev *priv = dev_get_drvdata(dev);

    ret = kstrtou32(buf, 0, &switch_reg);
    if (ret < 0) 
    {
        return ret;
    }

    iowrite32(switch_reg, priv->switch_reg);

    return size;
}

static DEVICE_ATTR_RW(led_control);
static DEVICE_ATTR_RW(period);
static DEVICE_ATTR_RW(led_red);
static DEVICE_ATTR_RW(led_blue);
static DEVICE_ATTR_RW(led_green);
static DEVICE_ATTR_RW(switch_reg);


static struct attribute *rgb_control_attrs[] = {
    &dev_attr_led_control.attr,
    &dev_attr_period.attr,
    &dev_attr_led_red.attr,
    &dev_attr_led_blue.attr,
    &dev_attr_led_green.attr,
    &dev_attr_switch_reg.attr,

    NULL,
};
ATTRIBUTE_GROUPS(rgb_control);

/*
*	FILE OPERATIONS
*/ 
static const struct file_operations rgb_control_fops = {
    .owner = THIS_MODULE,
    .read = rgb_control_read,
    .write = rgb_control_write,
    .llseek = default_llseek,
};
/*
*	PROBE FUNCTION
*/
static int rgb_control_probe(struct platform_device *pdev)
{
    struct rgb_control_dev *priv;
    size_t ret;
    

    priv = devm_kzalloc(&pdev->dev, sizeof(struct rgb_control_dev), 
    			GFP_KERNEL);
    if (!priv) 
    {
        pr_err("Failed to allocate memory\n");
        return -ENOMEM;
    }

    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) 
    {
        pr_err("Failed to request/remap platform device resource\n");
        return PTR_ERR(priv->base_addr);
    }

    priv->led_control = priv->base_addr + LED_CTRL_OFFSET;
    priv->period = priv->base_addr + PERIOD_OFFSET;
    priv->led_red = priv->base_addr + LED_RED_OFFSET;
    priv->led_blue = priv->base_addr + LED_BLUE_OFFSET;
    priv->led_green = priv->base_addr + LED_GREEN_OFFSET;
    priv->switch_reg = priv->base_addr + SW_REGISTER_OFFSET;

    iowrite32(0x200, priv->led_control);
    iowrite32(0xcd, priv->period);
    iowrite32(0x200, priv->led_red);
    iowrite32(0x200, priv->led_blue);
    iowrite32(0x200, priv->led_green);
    iowrite32(0x0, priv->switch_reg);

    
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "rgb_control";
    priv->miscdev.fops = &rgb_control_fops;
    priv->miscdev.parent = &pdev->dev;
    
    ret = misc_register(&priv->miscdev);
    if (ret) 
    {
    	pr_err("Failed to register misc device");
    	return ret;
    }

    platform_set_drvdata(pdev, priv);

    pr_info("rgb_control_probe successful\n");
    return 0;
}
/*
*	REMOVE FUNCTION
*/
static int rgb_control_remove(struct platform_device *pdev)
{
    struct rgb_control_dev *priv = platform_get_drvdata(pdev);

    iowrite32(0, priv->led_control);
    misc_deregister(&priv->miscdev);

    pr_info("rgb_control_remove successful\n");
    
    return 0;
}
/*
*	PLATFORM DRIVER
*/
static const struct of_device_id rgb_control_of_match[] = {
    { .compatible = "hexom,rgb_controller_0", },
    { }
};
MODULE_DEVICE_TABLE(of, rgb_control_of_match);

static struct platform_driver rgb_control_driver = {
    .probe = rgb_control_probe,
    .remove = rgb_control_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "rgb_control",
        .of_match_table = rgb_control_of_match,
        .dev_groups = rgb_control_groups, 
    },
};
/*
*	REGISTER
*/
module_platform_driver(rgb_control_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Jordy Hexom");
MODULE_DESCRIPTION("rgb_control platform driver");
