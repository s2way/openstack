
package 'openstack-dashboard' do
    options '-y --force-yes'
end

mysql_connection_info = {
    :host     => node['openstack']['db']['host'],
    :username => 'root',
    :password => node['openstack']['db']['root_password']
}

mysql_database node['openstack']['horizon']['db_name'] do
  connection mysql_connection_info
  action :create
end
mysql_database_user node['openstack']['horizon']['db_user'] do
  connection mysql_connection_info
  password   node['openstack']['horizon']['db_pass']
  action     :create
end
mysql_database_user node['openstack']['horizon']['db_user'] do
  connection    mysql_connection_info
  password      node['openstack']['horizon']['db_pass']
  database_name node['openstack']['horizon']['db_name']
  host          '%'
  privileges    [:all]
  action        :grant
end
mysql_database_user node['openstack']['horizon']['db_user'] do
  connection    mysql_connection_info
  password      node['openstack']['horizon']['db_pass']
  database_name node['openstack']['horizon']['db_name']
  host          'localhost'
  privileges    [:all]
  action        :grant
end


file '/etc/openstack-dashboard/local_settings.py' do
    content "
import os

from django.utils.translation import ugettext_lazy as _

from horizon.utils import secret_key

from openstack_dashboard import exceptions
from openstack_dashboard.settings import HORIZON_CONFIG

DEBUG = False
TEMPLATE_DEBUG = DEBUG

WEBROOT = '/'
LOCAL_PATH = os.path.dirname(os.path.abspath(__file__))

SECRET_KEY = secret_key.generate_or_read_from_file('/var/lib/openstack-dashboard/secret_key')

# SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
#
# CACHES = {
#     'default': {
#         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
#         'LOCATION': 'controller:11211',
#     }
# }

SESSION_ENGINE = 'django.contrib.sessions.backends.db'
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '#{node['openstack']['horizon']['db_name']}',
        'USER': '#{node['openstack']['horizon']['db_user']}',
        'PASSWORD': '#{node['openstack']['horizon']['db_pass']}',
        'HOST': '#{node['openstack']['db']['host']}',
        'default-character-set': 'utf8'
    }
}

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

OPENSTACK_HOST = 'controller'
OPENSTACK_KEYSTONE_URL = \"http://%s:5000/v3\" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"

OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

OPENSTACK_API_VERSIONS = {
    \"identity\": 3,
    \"image\": 2,
    \"volume\": 2,
}

OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = \"default\"


OPENSTACK_KEYSTONE_BACKEND = {
    'name': 'native',
    'can_edit_user': True,
    'can_edit_group': True,
    'can_edit_project': True,
    'can_edit_domain': True,
    'can_edit_role': True,
}

OPENSTACK_HYPERVISOR_FEATURES = {
    'can_set_mount_point': False,
    'can_set_password': False,
    'requires_keypair': False,
}

OPENSTACK_CINDER_FEATURES = {
    'enable_backup': False,
}

OPENSTACK_NEUTRON_NETWORK = {
    'enable_router': True,
    'enable_quotas': True,
    'enable_ipv6': True,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': True,
    'enable_firewall': True,
    'enable_vpn': True,
    'enable_fip_topology_check': True,
    'default_ipv4_subnet_pool_label': None,
    'default_ipv6_subnet_pool_label': None,
    'profile_support': None,
    'supported_provider_types': ['*'],
    'supported_vnic_types': ['*'],
}

OPENSTACK_HEAT_STACK = {
    'enable_user_pass': True,
}

IMAGE_CUSTOM_PROPERTY_TITLES = {
    'architecture': _('Architecture'),
    'kernel_id': _('Kernel ID'),
    'ramdisk_id': _('Ramdisk ID'),
    'image_state': _('Euca2ools state'),
    'project_id': _('Project ID'),
    'image_type': _('Image Type'),
}

IMAGE_RESERVED_CUSTOM_PROPERTIES = []

API_RESULT_LIMIT = 1000
API_RESULT_PAGE_SIZE = 20

SWIFT_FILE_TRANSFER_CHUNK_SIZE = 512 * 1024

DROPDOWN_MAX_ITEMS = 30

TIME_ZONE = 'UTC'


LOGGING = {
    'version': 1,

    'disable_existing_loggers': False,
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'logging.NullHandler',
        },
        'console': {

            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {


        'django.db.backends': {
            'handlers': ['null'],
            'propagate': False,
        },
        'requests': {
            'handlers': ['null'],
            'propagate': False,
        },
        'horizon': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'openstack_dashboard': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'novaclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'cinderclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'keystoneclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'glanceclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'neutronclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'heatclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'ceilometerclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'swiftclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'openstack_auth': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'nose.plugins.manager': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'iso8601': {
            'handlers': ['null'],
            'propagate': False,
        },
        'scss': {
            'handlers': ['null'],
            'propagate': False,
        },
    },
}

SECURITY_GROUP_RULES = {
    'all_tcp': {
        'name': _('All TCP'),
        'ip_protocol': 'tcp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_udp': {
        'name': _('All UDP'),
        'ip_protocol': 'udp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_icmp': {
        'name': _('All ICMP'),
        'ip_protocol': 'icmp',
        'from_port': '-1',
        'to_port': '-1',
    },
    'ssh': {
        'name': 'SSH',
        'ip_protocol': 'tcp',
        'from_port': '22',
        'to_port': '22',
    },
    'smtp': {
        'name': 'SMTP',
        'ip_protocol': 'tcp',
        'from_port': '25',
        'to_port': '25',
    },
    'dns': {
        'name': 'DNS',
        'ip_protocol': 'tcp',
        'from_port': '53',
        'to_port': '53',
    },
    'http': {
        'name': 'HTTP',
        'ip_protocol': 'tcp',
        'from_port': '80',
        'to_port': '80',
    },
    'pop3': {
        'name': 'POP3',
        'ip_protocol': 'tcp',
        'from_port': '110',
        'to_port': '110',
    },
    'imap': {
        'name': 'IMAP',
        'ip_protocol': 'tcp',
        'from_port': '143',
        'to_port': '143',
    },
    'ldap': {
        'name': 'LDAP',
        'ip_protocol': 'tcp',
        'from_port': '389',
        'to_port': '389',
    },
    'https': {
        'name': 'HTTPS',
        'ip_protocol': 'tcp',
        'from_port': '443',
        'to_port': '443',
    },
    'smtps': {
        'name': 'SMTPS',
        'ip_protocol': 'tcp',
        'from_port': '465',
        'to_port': '465',
    },
    'imaps': {
        'name': 'IMAPS',
        'ip_protocol': 'tcp',
        'from_port': '993',
        'to_port': '993',
    },
    'pop3s': {
        'name': 'POP3S',
        'ip_protocol': 'tcp',
        'from_port': '995',
        'to_port': '995',
    },
    'ms_sql': {
        'name': 'MS SQL',
        'ip_protocol': 'tcp',
        'from_port': '1433',
        'to_port': '1433',
    },
    'mysql': {
        'name': 'MYSQL',
        'ip_protocol': 'tcp',
        'from_port': '3306',
        'to_port': '3306',
    },
    'rdp': {
        'name': 'RDP',
        'ip_protocol': 'tcp',
        'from_port': '3389',
        'to_port': '3389',
    },
}

REST_API_REQUIRED_SETTINGS = ['OPENSTACK_HYPERVISOR_FEATURES',
                              'LAUNCH_INSTANCE_DEFAULTS']

###############################################################################
# Ubuntu Settings
###############################################################################

try:
  from ubuntu_theme import *
except ImportError:
  pass

WEBROOT='/horizon/'

ALLOWED_HOSTS = ['*', ]

COMPRESS_OFFLINE = True

"
end

directory '/var/lib/dash/.blackhole' do
    recursive true
end
